// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract ArtProject {
    struct Pool {
        bool exists;
        string name;
        mapping(address => Beneficiary) beneficiaries;
        uint numberOfBeneficiaries;
    }

    struct Beneficiary {
        address account;
        uint basisPoints;
    }

    error alreadyExists(string , address);
    error doesNotExist(string error);
    error isNotAdministrator();

    address public immutable i_administrator;

    mapping(address => bool) public accounts;
    mapping(string => Pool) public pools;

    constructor() {
        i_administrator = msg.sender;
    }

    modifier restrictedToAdministrator() {
        if (msg.sender != i_administrator) { revert isNotAdministrator(); }
        _;
    }

    function addPool(string memory name) public restrictedToAdministrator {
        if (pools[name].exists) { revert alreadyExists(string.concat("pool """, name, """"), address(0)); }
        pools[name].exists = true;
        pools[name].name = name;
    }

    function addBeneficiaryToPool(address account, string memory name) public restrictedToAdministrator {
        if (!pools[name].exists) { revert doesNotExist(name); }
        if (accounts[account]) { revert alreadyExists("beneficiary", account); }
        accounts[account] = true;

        Beneficiary memory beneficiary;
        beneficiary.account = account;
        pools[name].beneficiaries[account] = beneficiary;
        pools[name].numberOfBeneficiaries++;
    }
}
