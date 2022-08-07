// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interface/IGovernanceModule.sol";
import "./AbstractGovernanceModule.sol";
import '../organisation/interface/ITeamFactory.sol';

contract LDAOTeamDeploymentModule is AbstractGovernanceModule {
    struct ProposedTeam {
        string name;
    }
    address private _teamFactory;

    constructor(address teamFactory) {
        _teamFactory = teamFactory;
    }

    mapping(uint256 => ProposedTeam) private _proposedTeams;

    function proposeTeamDeployment(
        string memory teamName,
        string memory proposalTitle
    ) public returns (uint256){
        uint256 proposalId = _saveProposal(proposalTitle);
        ProposedTeam storage team = _proposedTeams[proposalId];
        team.name = teamName;
        return proposalId;
    }

    function getExtraData(uint256 proposalId)
        public
        view
        returns (ProposedTeam memory)
    {
        return _proposedTeams[proposalId];
    }

    function execute(uint256 proposalId) external override {
        ITeamFactory fac = ITeamFactory(_teamFactory);
        fac.deployTeam(_proposedTeams[proposalId].name);
    }
}
