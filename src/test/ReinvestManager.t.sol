// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "src/Pair.sol";
import "src/Factory.sol";
import "src/DYSON.sol";
import "src/sDYSON.sol";
import "src/ReinvestManager.sol";
import "src/interface/IERC20.sol";
import "./TestUtils.sol";

contract ReinvestManagerTest is TestUtils {
    address testOwner = address(this);
    address token1 = address(new DYSON(testOwner));
    address token0 = address(new DYSON(testOwner));
    Factory factory = new Factory(testOwner);
    Pair normalPair = Pair(factory.createPair(token0, token1));
    ReinvestManager reinvestManager = new ReinvestManager(testOwner);
    
    address gov = address(new DYSON(testOwner));
    address sGov = address(new sDYSON(testOwner, gov));

    bytes32 public constant REinvest_TYPEHASH = keccak256("reinvest(address noteOwner,address pair,uint256 lockTime,uint256 startTime,uint256 endTime,uint256 priceCeiling,uint256 priceFloor,uint256 frequencyLimit,uint256 nonce)");
    uint constant PRICE_BASE_UNIT = 1e18;
    uint constant INITIAL_LIQUIDITY_TOKEN = 10**24; // 1M tokens

    // Handy accounts
    address alice = _nameToAddr("alice");
    uint constant INITIAL_WEALTH = 1e30;

    address noteOwner;
    uint lockTime;
    uint startTime;
    uint endTime;
    uint priceCeiling;
    uint priceFloor;
    uint frequencyLimit;

    function setUp() public {
        // Make sure variable names are matched.
        assertEq(normalPair.token0(), token0);
        assertEq(normalPair.token1(), token1);

        // Initialize token0 and token1 for pairs.
        deal(token0, address(normalPair), INITIAL_LIQUIDITY_TOKEN);
        deal(token1, address(normalPair), INITIAL_LIQUIDITY_TOKEN);

        reinvestManager.rely(token0, address(normalPair), true);
        reinvestManager.rely(token1, address(normalPair), true);
    
        // Initialize tokens and eth for handy accounts.
        deal(token0, alice, INITIAL_WEALTH);
        deal(token1, alice, INITIAL_WEALTH);
        deal(alice, INITIAL_WEALTH);

        uint input = 10e18;
        uint minOutput = 0;
        uint time = 1 days;
        
        // Appoving.
        vm.startPrank(alice);
        IERC20(token0).approve(address(reinvestManager), type(uint).max);
        IERC20(token1).approve(address(reinvestManager), type(uint).max);

        IERC20(token0).approve(address(normalPair), type(uint).max);
        IERC20(token1).approve(address(normalPair), type(uint).max);

        // deposit to pair (dual investment)
        normalPair.deposit0(alice, input, minOutput, time);
        normalPair.setApprovalForAll(address(reinvestManager), true);
        vm.stopPrank();

        // Check if the note is deposited to the pair
        uint count = normalPair.noteCount(alice);
        assertEq(count, 1);

        // Alice reinvest confirguration
        noteOwner = alice;
        lockTime = 1 days;
        startTime = block.timestamp + 2 days;
        endTime = startTime + 30 days;
        priceCeiling = 1.2e18;
        priceFloor = 0.8e18;
        frequencyLimit = 3;
    }

    function testReinvest() public {
        // Check noteOwner has only one note in the pair
        assertEq(normalPair.noteCount(noteOwner), 1);

        bytes memory sig = signReinvestSig(noteOwner, lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit);
        
        skip(2 days); // skip 2 day because startTime is 2 days later
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);

        // Check if the note is deposited to the pair
        assertEq(normalPair.noteCount(noteOwner), 2);
    }

    function testReinvestRevertBeforeStartTime() public {
        bytes memory sig = signReinvestSig(noteOwner, lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit);
        
        skip(1 days); // not start yet
        vm.expectRevert("reinvest time has not started");
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);
    }

    function testReinvestRevertAfterEndTime() public {
        bytes memory sig = signReinvestSig(noteOwner, lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit);
        
        skip(60 days); // alread ended
        vm.expectRevert("reinvest time has ended");
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);
    }

    function testReinvestRevertWhenReachFrequencyLimit() public {
        // Check noteOwner has only one note in the pair
        assertEq(normalPair.noteCount(noteOwner), 1);

        bytes memory sig = signReinvestSig(noteOwner, lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit);
        
        skip(2 days); // skip 2 day because startTime is 2 days later
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);

        skip(1 days); 
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);
        
        skip(1 days); 
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);

        // Check if the 3 notes are deposited to the pair
        assertEq(normalPair.noteCount(noteOwner), 4);

        skip(1 days); 
        vm.expectRevert("frequency limit reached");
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);
    }

    function testCancelReinvest() public {
        bytes memory sig = signReinvestSig(noteOwner, lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit);

        vm.prank(noteOwner);
        reinvestManager.cancelReinvest(noteOwner);

        skip(2 days);
        vm.expectRevert("invalid signature");
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);
    }

    function testReinvestWhenUserHasMultipleNotes() public {
        uint input = 20e18;
        uint minOutput = 0;
        uint time = 1 days;

        vm.startPrank(alice);
        normalPair.deposit0(alice, input, minOutput, time);
        normalPair.deposit0(alice, input, minOutput, time);
        normalPair.deposit0(alice, input, minOutput, time);
        vm.stopPrank();

        // Check noteOwner has 4 notes in the pair
        assertEq(normalPair.noteCount(alice), 4);

        bytes memory sig = signReinvestSig(noteOwner, lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit);
        
        skip(2 days); // skip 2 day because startTime is 2 days later
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);

        // Check if the note is deposited to the pair
        assertEq(normalPair.noteCount(noteOwner), 5);
        // Check the noteId 1 is withdrawn
        (uint token0Amt, uint token1Amt,) = normalPair.notes(noteOwner, 1);
        assertEq(token0Amt, 0);
        assertEq(token1Amt, 0);

        skip(1 days); 
        reinvestManager.reinvest(noteOwner, address(normalPair), lockTime, startTime, endTime, priceCeiling, priceFloor, frequencyLimit, sig);

        // Check if the new note is deposited to the pair
        assertEq(normalPair.noteCount(noteOwner), 6);
        // Check the noteId 2 is withdrawn
        (token0Amt, token1Amt,) = normalPair.notes(noteOwner, 2);
        assertEq(token0Amt, 0);
        assertEq(token1Amt, 0);

    }

    function signReinvestSig(
        address _noteOwner,
        uint _lockTime,
        uint _startTime,
        uint _endTime,
        uint _priceCeiling,
        uint _priceFloor,
        uint _frequencyLimit
    ) internal view returns (bytes memory) {
        bytes32 structHash = sigStructHash(_noteOwner, address(normalPair), _lockTime, _startTime, _endTime, _priceCeiling, _priceFloor, _frequencyLimit);
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", reinvestDomainSeparator(), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_nameToKey("alice"), digest);
        return abi.encodePacked(r, s, v);
    }

    function reinvestDomainSeparator() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("Reinvest")),
                keccak256(bytes("1")), 
                block.chainid,
                address(reinvestManager)
            )
        );
    }

    function sigStructHash(
        address _noteOwner,
        address _pair,
        uint _lockTime,
        uint _startTime,
        uint _endTime,
        uint _priceCeiling,
        uint _priceFloor,
        uint _frequencyLimit
    ) internal view returns (bytes32) {
        bytes memory m1 = abi.encode(_noteOwner, _pair, _lockTime);
        bytes memory m2 = abi.encode( _startTime, _endTime, _priceCeiling);
        bytes memory m3 = abi.encode(_priceFloor, _frequencyLimit, reinvestManager.nonces(_noteOwner));
        return keccak256(bytes.concat(m1, m2, m3));
    }
}