// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "../src/VerifyPredicatesLogic.sol";
import "../src/Predicates.sol";
import "../src/GenerateCalldata.sol";
import "../src/TargetContract.sol";

contract VerifyPredicatesLogicTest is Test {
    VerifyPredicatesLogic public verifyPredicate;
    TargetContract public targetContract;
    GenerateCalldata public generateCalldata;
    Predicates public predicateContract;

    function setUp() public {
        predicateContract = new Predicates();
        verifyPredicate = new VerifyPredicatesLogic(address(predicateContract));
        targetContract = new TargetContract();
        generateCalldata = new GenerateCalldata(address(targetContract));
    }

    function test_calldata_1() public {
        bytes memory predicate = generateCalldata.generateCalldata1();
        verifyPredicate.verify(predicate);
    }

    function test_calldata_2() public {
        bytes memory predicate = generateCalldata.generateCalldata2();
        verifyPredicate.verify(predicate);
    }
}
