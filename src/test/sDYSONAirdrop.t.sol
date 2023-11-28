// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "src/sDYSON.sol";
import "src/DYSON.sol";
import "src/util/sDYSONAirdrop.sol";
import "src/test/TestUtils.sol";

contract sDYSONAirdropTest is TestUtils {

    sDYSONAirdrop public airdrop;
    sDYSON public sDyson;
    DYSON public dyson;
    address public owner = address(this);

    /*
    MerkleRoot:            root
                        /        \
    level 1:         node1       node2 
                    /    \       /    \         
    leve 2:     node3  node4   node5  node6 
              (user1) (user2) (user3) (user4)
    */

    address user1 = vm.addr(1); // amount: 100, index: 1
    address user2 = vm.addr(2); // amount: 200, index: 2
    address user3 = vm.addr(3); // amount: 300, index: 3
    address user4 = vm.addr(4); // amount: 400, index: 4

    uint amount1 = 100e18;
    uint amount2 = 200e18;
    uint amount3 = 300e18;
    uint amount4 = 400e18;

    uint id1 = 1;
    uint id2 = 2;
    uint id3 = 3;
    uint id4 = 4;

    bytes32 node6;
    bytes32 node5;
    bytes32 node4;
    bytes32 node3;
    bytes32 node2;
    bytes32 node1;
    bytes32 root;

    uint airdropWealth = amount1 + amount2 + amount3 + amount4;
    uint claimStartTime;
    uint claimEndTime;
    bytes32[] merkleProof = new bytes32[](2);

    function setUp() public {
        dyson = new DYSON(owner);
        sDyson = new sDYSON(owner, address(dyson));
        StakingRateModel rateModel = new StakingRateModel(0.0625e18);
        sDyson.setStakingRateModel(address(rateModel));

        node6 = keccak256(abi.encodePacked(id4, user4, amount4));
        node5 = keccak256(abi.encodePacked(id3, user3, amount3));
        node4 = keccak256(abi.encodePacked(id2, user2, amount2));
        node3 = keccak256(abi.encodePacked(id1, user1, amount1));
        node2 = hashPair(node5, node6);
        node1 = hashPair(node3, node4);
        root = hashPair(node1, node2);

        claimStartTime = block.timestamp + 1 hours;
        claimEndTime = block.timestamp + 2 days;

        airdrop = new sDYSONAirdrop(owner, address(dyson), address(sDyson), root, claimStartTime, claimEndTime);
        deal(address(dyson), address(airdrop), airdropWealth);
    }

    function testClaim() public {
        skip(1 hours + 1);

        merkleProof[0] = node5;
        merkleProof[1] = node1;

        // user4 claim
        airdrop.claim(id4, user4, amount4, merkleProof);

        assertEq(sDyson.dysonAmountStaked(user4), amount4);
    }

    function testClaimRevertWithWrongAmount() public {
        skip(1 hours + 1);

        merkleProof[0] = node5;
        merkleProof[1] = node1;

        // user4 claim
        vm.expectRevert("Airdrop: Invalid proof");
        airdrop.claim(id4, user4, 300, merkleProof);
    }

    function testClaimRevertWithWrongAddress() public {
        skip(1 hours + 1);

        merkleProof[0] = node5;
        merkleProof[1] = node1;

        // user4 claim
        vm.expectRevert("Airdrop: Invalid proof");
        airdrop.claim(id4, user3, amount4, merkleProof);
    }

    function testClaimRevertWithWrongId() public {
        skip(1 hours + 1);

        merkleProof[0] = node5;
        merkleProof[1] = node1;

        // user4 claim
        vm.expectRevert("Airdrop: Invalid proof");
        airdrop.claim(id3, user4, amount4, merkleProof);
    }

    function testClaimRevertWithWrongProof() public {
        skip(1 hours + 1);

        merkleProof[0] = node3;
        merkleProof[1] = node1;

        // user4 claim
        vm.expectRevert("Airdrop: Invalid proof");
        airdrop.claim(id4, user4, amount4, merkleProof);
    }

    function testClaimRevertWhenIsClaimed() public {
        skip(1 hours + 1);

        merkleProof[0] = node5;
        merkleProof[1] = node1;

        // user4 claim
        airdrop.claim(id4, user4, amount4, merkleProof);
        vm.expectRevert("Airdrop: Drop already claimed.");
        airdrop.claim(id4, user4, amount4, merkleProof);
    }

    function testOwnerWithdraw() public {
        skip(1 hours + 1);
        // user4 claim
        merkleProof[0] = node5;
        merkleProof[1] = node1;
        airdrop.claim(id4, user4, amount4, merkleProof);

        // user2 claim
        merkleProof[0] = node3;
        merkleProof[1] = node2;
        airdrop.claim(id2, user2, amount2, merkleProof);

        skip(2 days + 1);

        uint amountLeft = airdropWealth - amount2 - amount4;
        uint balance = dyson.balanceOf(address(airdrop));
        assertEq(balance, amountLeft);
        airdrop.ownerWithdraw();
        assertEq(dyson.balanceOf(address(airdrop)), 0);
        assertEq(dyson.balanceOf(owner), amountLeft);
    }

    function hashPair(bytes32 a, bytes32 b) public pure returns (bytes32 node) {
        if(a < b) node = keccak256(abi.encodePacked(a, b));
        else node = keccak256(abi.encodePacked(b, a));
    }
}