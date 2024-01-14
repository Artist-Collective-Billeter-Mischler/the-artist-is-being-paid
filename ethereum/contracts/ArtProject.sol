// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract ArtProject {
    struct Pool {
        string name;
        address[] recipients;
    }

    error isNotAdministrator();

    address public immutable i_administrator;
    Pool[] public pools;

    constructor() {
        i_administrator = msg.sender;
    }

    modifier restrictedToAdministrator() {
        if (msg.sender != i_administrator) { revert isNotAdministrator(); }
        _;
    }

    function addPool(string memory name) public restrictedToAdministrator {
        address[] memory recipients;
        pools.push(Pool(name, recipients));
    }
}
