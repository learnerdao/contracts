// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import './AbstractGovernanceModule.sol';
import '../organisation/interface/ITeamFactory.sol';
import '../organisation/interface/ITeam.sol';

contract LDAOTeamEmployModule is AbstractGovernanceModule {

    address private _teamFactory;
    struct ProposedEmployee {
        address employee;
        address teamAddress;
    }
    mapping(uint256 => ProposedEmployee) private _proposedEmployees;

    constructor(address teamFactory) {
        _teamFactory = teamFactory;
    }

    function proposeTeamUnEmployment(address employee, uint256 teamId, string memory title) public {
          ITeamFactory fac = ITeamFactory(_teamFactory);
          address[] memory teams = fac.enumerateTeams();
          require(teams.length < teamId, "Provided Team ID doesnt exist.");
          address teamAddr = teams[teamId];
          ITeam team = ITeam(teamAddr);
          require(!team.isMember(employee), "Proposed team member is already part of this team.");
          uint256 proposalId = _saveProposal(title);
          ProposedEmployee storage proposedEmployee = _proposedEmployees[proposalId];
          proposedEmployee.employee = employee;
          proposedEmployee.teamAddress = teamAddr;
    }

    function execute(uint256 proposalId) external override {
        ProposedEmployee storage data = _proposedEmployees[proposalId];
        ITeam team = ITeam(data.teamAddress);
        team.leaveTeam(data.employee);
    }
}