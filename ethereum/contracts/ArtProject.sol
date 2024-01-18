// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract ArtProject {
    uint constant TOTAL_BASIS_POINTS = 10000;

    struct Pool {
        address[] accounts;
        uint basisPoints;
        mapping(address => Beneficiary) beneficiaries;
        bool exists;
        string name;
    }

    struct Beneficiary {
        address account;
        uint basisPoints;
    }

    error alreadyExists(string , address);
    error doesNotExist(string error);
    error isNotAdministrator();

    address public immutable i_administrator;

    address[] public accounts;
    mapping(address => uint) public distributionKey;
    mapping(address => bool) public existingAccounts;
    string[] public poolNames;
    mapping(string => Pool) public pools;
    string public residualDonationsPoolName;

    constructor() {
        i_administrator = msg.sender;
    }

    modifier restrictedToAdministrator() {
        if (msg.sender != i_administrator) { revert isNotAdministrator(); }
        _;
    }

    function addBeneficiaryToPool(address account, string memory name) public restrictedToAdministrator {
        if (!pools[name].exists) { revert doesNotExist(name); }
        if (existingAccounts[account]) { revert alreadyExists("beneficiary", account); }

        accounts.push(account);
        existingAccounts[account] = true;

        Beneficiary memory beneficiary;
        beneficiary.account = account;
        pools[name].accounts.push(account);
        pools[name].beneficiaries[account] = beneficiary;
    }

    function addPool(string memory name, uint basisPoints) public restrictedToAdministrator {
        Pool storage pool;

        if (pools[name].exists) { revert alreadyExists(string.concat("pool: ", name), address(0)); }

        poolNames.push(name);
        
        pool = pools[name];
        pool.exists = true;
        pool.name = name;
        pool.basisPoints = basisPoints;

        if (basisPoints == 0) {
            residualDonationsPoolName = name;
        }
    }

    function calculateDistributionKey() public restrictedToAdministrator {
        address account;
        uint assignedBasisPoints;
        Pool storage pool;
        uint remainingBasisPoints;

        for (uint poolIndex = 0;  poolIndex < poolNames.length; poolIndex ++) {
            assignedBasisPoints += pools[poolNames[poolIndex]].basisPoints;
        }

        remainingBasisPoints = TOTAL_BASIS_POINTS - assignedBasisPoints;
        assignedBasisPoints = 0;

        for (uint poolIndex = 0; poolIndex < poolNames.length; poolIndex++) {
            pool = pools[poolNames[poolIndex]];

            if (keccak256(bytes(pool.name)) == keccak256(bytes(residualDonationsPoolName))) { continue; }

            assignedBasisPoints += updateDistributionKey(pool, pool.basisPoints / pool.accounts.length);
        }

        pool = pools[residualDonationsPoolName];
        remainingBasisPoints = TOTAL_BASIS_POINTS - assignedBasisPoints;
        assignedBasisPoints += updateDistributionKey(pool, remainingBasisPoints / pool.accounts.length);

        remainingBasisPoints = TOTAL_BASIS_POINTS - assignedBasisPoints;
        account = pool.accounts[pool.accounts.length - 1];
        distributionKey[account] += remainingBasisPoints;
    }

    function getDistriptionKey() public view returns (address[] memory, uint[] memory) {
        uint[] memory basisPoints = new uint[](accounts.length);

        for (uint index = 0; index < accounts.length; index++) {
            basisPoints[index] = distributionKey[accounts[index]];
        }

        return (accounts, basisPoints);
    }

    function updateDistributionKey(Pool storage pool, uint basisPoints) private returns (uint) {
        uint assignedBasisPoints;

        for (uint beneficiaryIndex = 0; beneficiaryIndex < pool.accounts.length; beneficiaryIndex++) {
            address account = pool.accounts[beneficiaryIndex];
            distributionKey[account] = basisPoints;
            assignedBasisPoints += basisPoints;
        }

        return assignedBasisPoints;
    }
}
