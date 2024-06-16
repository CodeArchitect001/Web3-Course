// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Datalocations {
    uint256[] public arr;
    mapping (uint256 => address) map;

    struct MyStruct {
        uint256 foo;
    }

    mapping (uint256 => MyStruct) myStructs;
    
    function f() public {
        //call _f with state variable
        _f(arr,map,myStructs[1]);
    }

    function _f(
        uint256[] storage _arr,
        mapping (uint256 => address) storage _map,
        MyStruct storage _muStruct
    ) internal {
        // dp somting with storage variables
    }


    //you can return memory variables
    function g(uint256[] memory _arr) public returns (uint256[] memory){
        // do something with memory array
    }

    function h(uint256[] calldata _arr) external {
        //do somting with calldata array
    }
}