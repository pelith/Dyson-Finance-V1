pragma solidity 0.8.17;

// SPDX-License-Identifier: AGPL-3.0-only

import "interface/IPair.sol";
import "interface/IFactory.sol";
import "./lib/TransferHelper.sol";

contract ReinvestManager {
    using TransferHelper for address;

    address owner;
    /// @dev For EIP712
    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant REinvest_TYPEHASH = keccak256("reinvest(address noteOwner,address pair,uint256 lockTime,uint256 startTime,uint256 endTime,uint256 priceCeiling,uint256 priceFloor,uint256 frequencyLimit,uint256 nonce)");

    /// @notice User's reinvest nonce
    mapping(address => uint256) public nonces;

    /// noteOwner => (pair => frequency)
    mapping(address => mapping(address => uint)) public reinvestFrequency;

    uint constant PRICE_BASE_UNIT = 1e18;

    event TransferOwnership(address newOwner);
    event Reinvest(uint withdrawNoteId, uint reinvestNoteId);

    constructor(address _owner) {
        require(_owner != address(0), "owner cannot be zero");
        owner = _owner;
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("Reinvest")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "forbidden");
        _;
    }

    /// @notice Allow another address to transfer token from this contract
    /// @param tokenAddress Address of token to approve
    /// @param contractAddress Address to grant allowance
    /// @param enable True to enable allowance. False otherwise.
    function rely(address tokenAddress, address contractAddress, bool enable) onlyOwner external {
        tokenAddress.safeApprove(contractAddress, enable ? type(uint).max : 0);
    }

    /// @notice Withdraw and reinvest noteOwner's note in a specific pair
    /// @param noteOwner Address of note owner
    /// @param pair Address of pair
    /// @param lockTime Lock time of the new note
    /// @param startTime Valid start time of the reinvest
    /// @param endTime Valid end time of the reinvest
    /// @param priceCeiling Price ceiling of the reinvest
    /// @param priceFloor Price floor of the reinvest
    /// @param frequencyLimit Authorization for reinvestment frequency
    function reinvest(
        address noteOwner,
        address pair,
        uint lockTime,
        uint startTime,
        uint endTime,
        uint priceCeiling,
        uint priceFloor,
        uint frequencyLimit,
        bytes memory sig
    ) external { 
        uint frequency = reinvestFrequency[noteOwner][pair];
        require(frequencyLimit - frequency > 0, "frequency limit reached");
        bytes32 structHash = sigStructHash(
            noteOwner,
            pair,
            lockTime,
            startTime,
            endTime,
            priceCeiling,
            priceFloor,
            frequencyLimit
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        require(noteOwner == _ecrecover(digest, sig), "invalid signature");
        require(startTime < endTime, "startTime must be less than endTime");
        require(priceCeiling > priceFloor, "priceCeiling must be greater than priceFloor");
        require(frequencyLimit > 0, "frequencyLimit must be greater than 0");
        require(startTime <= block.timestamp, "reinvest time has not started");
        require(endTime >= block.timestamp, "reinvest time has ended");

        _reinvest(pair, noteOwner,lockTime, priceCeiling, priceFloor);

        reinvestFrequency[noteOwner][pair]++;

    }

    /// @notice Cancel the reinvest authorization by incrementing the nonce
    /// @param noteOwner Address of note owner
    function cancelReinvest(address noteOwner) external {
        require(msg.sender == noteOwner, "only note owner can cancel the reinvest");
        nonces[noteOwner]++;
    }

    function _reinvest(
        address pair,
        address noteOwner,
        uint lockTime,
        uint priceCeiling,
        uint priceFloor
    ) internal {
        // Find the notes of noteOwner
        uint count = IPair(pair).noteCount(noteOwner);
        uint withdrawNoteId;
        uint token0Amt;
        uint token1Amt;
        for (uint i = 1; i <= count; i++) {
            IPair.Note memory note = IPair(pair).notes(noteOwner, i);
            if (note.token0Amt != 0 || note.token1Amt != 0) {
                withdrawNoteId = i;
                break;
            }
        }

        (token0Amt, token1Amt) = IPair(pair).withdrawFrom(noteOwner, withdrawNoteId, address(this));
        
        if (token0Amt > 0) {
            uint minOutput = calcMinOutput(true, token0Amt, priceCeiling, priceFloor);
            IPair(pair).deposit0(noteOwner, token0Amt, minOutput, lockTime);
        } else {
            uint minOutput = calcMinOutput(false, token1Amt, priceCeiling, priceFloor);
            IPair(pair).deposit1(noteOwner, token1Amt, minOutput, lockTime);
        }
        emit Reinvest(withdrawNoteId, count + 1);
    }

    function sigStructHash(
        address noteOwner,
        address pair,
        uint lockTime,
        uint startTime,
        uint endTime,
        uint priceCeiling,
        uint priceFloor,
        uint frequencyLimit
    ) internal view returns (bytes32) {
        bytes memory m1 = abi.encode(noteOwner, pair, lockTime);
        bytes memory m2 = abi.encode(startTime, endTime, priceCeiling);
        bytes memory m3 = abi.encode(priceFloor, frequencyLimit, nonces[noteOwner]);
        return keccak256(bytes.concat(m1, m2, m3));
    }

    function calcMinOutput(
        bool isInput0,
        uint input,
        uint priceCeiling,
        uint priceFloor
    ) internal pure returns (uint) {
        if (isInput0) {
            // priceFloor = minOutput1 / input0
            uint minOutput1 = (priceFloor * input) / PRICE_BASE_UNIT;
            return minOutput1;
        } else {
            // priceCeiling = input1 / minOutput0
            uint minOutput0 = (input * PRICE_BASE_UNIT) / priceCeiling;
            return minOutput0;
        }
    }

    function _ecrecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }

            if (
                uint256(s) >
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
            ) {
                return address(0);
            } else if (v != 27 && v != 28) {
                return address(0);
            } else {
                return ecrecover(hash, v, r, s);
            }
        } else {
            return address(0);
        }
    }
}
