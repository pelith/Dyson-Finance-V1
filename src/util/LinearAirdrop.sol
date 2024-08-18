// SPDX-License-Identifier: GPL-v3-or-later
pragma solidity 0.8.17;

import "src/lib/MerkleProof.sol";
import "src/interface/IERC20.sol";
import "src/lib/TransferHelper.sol";

/**
 * @title LinearAirdrop
 * @dev Airdrop contract for DYSON
 */
contract LinearAirdrop {
    using TransferHelper for address;

    address public owner;
    address public dyson;
    mapping(uint256 => uint256) claimedBitMap;
    bytes32 public merkleRoot;

    uint claimStartTime;
    uint claimEndTime;

    event Claimed(uint256 index, address account, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner, address _dyson, bytes32 _merkleRoot, uint256 _claimStartTime, uint256 _claimEndTime) {
        require(_claimStartTime >= block.timestamp, "Airdrop: Invalid time");
        require(_claimStartTime <= _claimEndTime, "Airdrop: Invalid time");
        owner = _owner;
        dyson = _dyson;
        merkleRoot = _merkleRoot;
        claimStartTime = _claimStartTime;
        claimEndTime = _claimEndTime;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setAirdropTime (uint256 _claimStartTime, uint256 _claimEndTime) external onlyOwner {
        claimStartTime = _claimStartTime;
        claimEndTime = _claimEndTime;
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    /**
     * @notice Claim DYSON dirdrop.
     */
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external {
        require(!isClaimed(index), 'Airdrop: Drop already claimed.');
        require(msg.sender == account, 'Airdrop: Permission denied');
        require(block.timestamp < claimEndTime, "Airdrop: Expired");
        require(block.timestamp > claimStartTime, "Airdrop: Not started");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'Airdrop: Invalid proof');

        // Mark it claimed and send the token.
        _setClaimed(index);

        // Calculate the amount
        amount = amount * (block.timestamp - claimStartTime) / (claimEndTime - claimStartTime);
        // Transfer DYSON to account
        IERC20(dyson).safeTransfer(account, amount);

        emit Claimed(index, account, amount);
    }

    function ownerWithdraw() external onlyOwner {
        require(block.timestamp > claimEndTime, "Airdrop: Not ended");
        uint amount = IERC20(dyson).balanceOf(address(this));
        dyson.safeTransfer(owner, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Airdrop: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Airdrop: new owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}