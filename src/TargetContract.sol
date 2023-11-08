// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "forge-std/console.sol";

contract TargetContract {
    function dummyFn1() public pure returns (uint256) {
        return 7;
    }

    function dummyFn2() public pure returns (uint256) {
        return 18;
    }
}
