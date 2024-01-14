// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract ArtProject {
    struct Pool {
        string name;
        address[] recipients;
    }

    address public immutable administrator;
    Pool[] public pools;

    constructor() {
        administrator = msg.sender;
    }

    function addPool(string memory name) public {
        address[] memory recipients;
        pools.push(Pool(name, recipients));
    }
}
