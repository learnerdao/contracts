// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interface/ITeam.sol";

contract LDAOTeam is AccessControl, ITeam {
    bytes32 public constant EMPLOYER_ROLE = keccak256("EMPLOYER_ROLE");
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    string private _name;

    mapping(address => uint256) private _memberReputation;
    mapping(address => uint256) private _memberArrayIndex;
    mapping(uint256 => bool) private _memberActive;
    address[] private _members;
    uint256[] private _fundingPots;

    constructor(string memory name, address deployer) {
        _name = name;
        _grantRole(DEPLOYER_ROLE, deployer);
    }

    function joinTeam(address user) public onlyRole(EMPLOYER_ROLE) {
        _members.push(user);
        _memberArrayIndex[user] = _members.length - 1;
        _memberReputation[user] = 0;
        _memberActive[_members.length - 1] = true;
    }

    function leaveTeam(address user) public onlyRole(EMPLOYER_ROLE) {
        _memberActive[_memberArrayIndex[user]] = false;
    }

    function assignFundingPot(uint256 pot) public onlyRole(DEPLOYER_ROLE) {
        _fundingPots.push(pot);
    }

    // manages team members
    // manages funding (via role)
    // managed by governance module
}
