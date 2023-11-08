// SPDX-License-Identifier: MIT

import "forge-std/console.sol";

pragma solidity 0.8.21;

contract GenerateCalldata {
    address targetContract;

    constructor(address _targetContract) {
        targetContract = _targetContract;
    }

    function generateCalldata1() public view returns (bytes memory) {
        // English: Only allow order execution if the return value from an arbitrary call is less than 15.
        // Predicate: lt(15, arbitraryStaticCall(targetAddress, callDataToSendToTargetAddress))

        // Step 1: Generate calldata to send to our target contract

        bytes memory targetContractCalldata = abi.encodeWithSignature(
            "dummyFn1()"
        ); // 'callDataToSendToTargetAddress'

        // Step 2: Generate predicates contract "arbitrary static call" function calldata
        bytes memory arbitraryStaticCalldata = abi.encodeWithSignature(
            "arbitraryStaticCall(address,bytes)",
            targetContract,
            targetContractCalldata
        ); // arbitraryStaticCall(targetAddress, callDataToSendToTargetAddress)

        // Step 3: Generate predicates contract "lt" function calldata
        bytes memory ltFnCalldata = abi.encodeWithSignature(
            "lt(uint256,bytes)",
            15,
            arbitraryStaticCalldata
        ); // lt(15, arbitraryStaticCall(targetAddress, callDataToSendToTargetAddress))
        return ltFnCalldata;
    }

    function generateCalldata2() public view returns (bytes memory) {
        // English: Allow order execution if the return value from an arbitrary call is either less than 15 or greater than 5.
        // First, check if it's less than 15. If it isn't, then check if it's greater than 5. Allow order execution if either condition is true; disallow otherwise.
        // Predicate: or(lt(15, arbitraryStaticCall(targetAddress, callDataToSendToTargetAddress)), gt(5, arbitraryStaticCall(targetAddress, callDataToSendToTargetAddress)))
        // Note: It has 2 predicates, predicate#1 is 'lt' and predicate#2 is 'gt'

        // Step 1: Generate calldata to send to our target contract (for LT)
        bytes memory targetContractCalldata = abi.encodeWithSignature(
            "dummyFn1()"
        ); // 'callDataToSendToTargetAddress'

        // Step 2: Generate predicates contract "arbitrary static call" function calldata (for LT)
        bytes memory arbitraryStaticCalldata = abi.encodeWithSignature(
            "arbitraryStaticCall(address,bytes)",
            targetContract,
            targetContractCalldata
        ); // arbitraryStaticCall(targetAddress, callDataToSendToTargetAddress)

        // Step 3: Generate predicates contract "lt" function calldata
        bytes memory ltFnCalldata = abi.encodeWithSignature(
            "lt(uint256,bytes)",
            15,
            arbitraryStaticCalldata
        ); // lt(15, arbitraryStaticCall(targetAddress, callDataToSendToTargetAddress))

        // Helpful in generating bytes offset (see below)
        uint256 ltCalldataLength = bytes(ltFnCalldata).length;
        console.log("LT Calldata length ", ltCalldataLength);

        // Step 4: Generate calldata to send to our target contract (for GT)
        targetContractCalldata = abi.encodeWithSignature("dummyFn2()"); // 'callDataToSendToTargetAddress'

        // Step 5: Generate predicates contract "arbitrary static call" function calldata (for GT)
        arbitraryStaticCalldata = abi.encodeWithSignature(
            "arbitraryStaticCall(address,bytes)",
            targetContract,
            targetContractCalldata
        ); // arbitraryStaticCall(targetAddress, callDataToSendToTargetAddress)

        // Step 6: Generate predicates contract "gt" function calldata
        bytes memory gtFnCalldata = abi.encodeWithSignature(
            "gt(uint256,bytes)",
            5,
            arbitraryStaticCalldata
        ); // lt(15, arbitraryStaticCall(targetAddress, callDataToSendToTargetAddress))

        // Helpful in generating bytes offset (see below)
        uint256 gtCalldataLength = bytes(gtFnCalldata).length;
        console.log("GT Calldata length ", gtCalldataLength);

        // Step 7: generate 'offset' param value of 'or' fn of predicates contract

        // Generationg offset, required by 'or' fn of predicates contract
        // We have two predicates, length of both predicates in 260, so first predicate offset would be 260 and second would be "firstPredicateLength + 260 = 520"
        bytes memory offsetBytes = abi.encodePacked(uint32(520), uint32(260));

        // 'or' fn expects offset in uint256, so padding 0s
        for (uint256 i = (32 - offsetBytes.length) / 4; i > 0; i--) {
            offsetBytes = abi.encodePacked(uint32(0), offsetBytes);
        }
        uint256 offset = uint256(bytes32(offsetBytes));

        // Step 8: combine both 'lt' and 'gt' predicates
        bytes memory jointPredicates = abi.encodePacked(
            bytes(ltFnCalldata),
            bytes(gtFnCalldata)
        );

        // Step 9: Generating 'or' fn calldata
        bytes memory orFnCalldata = abi.encodeWithSignature(
            "or(uint256,bytes)",
            offset,
            jointPredicates
        );
        return orFnCalldata;
    }
}
