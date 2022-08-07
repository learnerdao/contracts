// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./LDAOTeam.sol";
import "../core/interface/ITreasury.sol";
import "./interface/ITeamFactory.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract LDAOTeamFactory is AccessControl, ITeamFactory {
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");

    address[] private _teams;
    address private _treasuryAddress;

    constructor(address deploymentModule) {
        _grantRole(DEPLOYER_ROLE, deploymentModule);
    }

    function setTreasuryAddress(address addr) public {
        require(
            _treasuryAddress == address(0),
            "Treasury Address already set."
        );
        _treasuryAddress = addr;
    }

    function deployTeam(string memory name) public onlyRole(DEPLOYER_ROLE) {
        LDAOTeam team = new LDAOTeam(name, address(this));
        _teams.push(address(team));
        ITreasury tres = ITreasury(_treasuryAddress);
        uint256 pot = tres.deployFundingPot();
        tres.addFundsHandler(address(team));
        team.assignFundingPot(pot);
        team.setPrimaryFundingPot(pot);
    }

    function enumerateTeams() public view override returns (address[] memory) {
        return _teams;
    }

    function teamFromId(uint256 id) public view override returns (address) {
        return _teams[id];
    }

    function getTeamPrimaryPotBalance(address team)
        public
        view
        override
        returns (uint256)
    {
        return
            ITreasury(_treasuryAddress).getAllocationForPot(
                LDAOTeam(team).getPrimaryPot()
            );
    }
}
