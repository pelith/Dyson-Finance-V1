// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import "forge-std/Script.sol";

contract Amounts is Script {

    function getAmounts(string memory addrId) internal returns (uint[] memory) {
        string memory file = vm.readFile("deploy-config.json");
        addrId = string.concat(".", addrId);
        return vm.parseJsonUintArray(file, addrId);
    }

    function getAmount(string memory addrId) internal returns (uint) {
        string memory file = vm.readFile("deploy-config.json");
        addrId = string.concat(".", addrId);
        return vm.parseJsonUint(file, addrId);
    }
}