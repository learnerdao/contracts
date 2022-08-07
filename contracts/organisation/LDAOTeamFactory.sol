// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./LDAOTeam.sol";
import "../core/LDAOTreasury.sol";
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
        LDAOTreasury tres = LDAOTreasury(_treasuryAddress);
        uint256 pot = tres.deployFundingPot();
        tres.addFundsHandler(address(team));
        team.assignFundingPot(pot);
    }

    function enumerateTeams() public view override returns (address[] memory) {
        return _teams;
    }
}
