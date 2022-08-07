// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import './AbstractGovernanceModule.sol';
import '../organisation/interface/ITeamFactory.sol';
import '../organisation/interface/ITeam.sol';
import '../core/interface/ITreasury.sol';

contract LDAOTreasuryAllocateFundsModule is AbstractGovernanceModule {

    struct ProposedTransfer {
        address teamTo;
        uint256 amount;
        uint256 escrowId;
    }

    mapping(uint256 => ProposedTransfer) private _proposals;
    address private _teamFactory;
    address private _treasury;

    constructor(address teamFactory, address treasury) {
        _teamFactory = teamFactory;
        _treasury = treasury;
    }

    function proposeTeamFundingAllocation(string memory title, uint256 teamId, uint256 fundsAmount) external returns (uint256) {
        ITeamFactory fac = ITeamFactory(_teamFactory);
        address team = fac.teamFromId(teamId);
        require(fac.getTeamPrimaryPotBalance(team) >= fundsAmount, "Transfer amount icannot be larger than team's primary pot balance");
        uint256 proposalId = _saveProposal(title);
        ProposedTransfer storage transfer = _proposals[proposalId];
        transfer.amount = fundsAmount;
        transfer.teamTo = team;

        uint256 toPot = ITeam(team).getPrimaryPot();
        transfer.escrowId = ITreasury(_treasury).escrowFundsFromTreasury(toPot, fundsAmount);
        return proposalId;
    }

    function execute(uint256 proposalId) external override {
         ITreasury(_treasury).releaseFunds(_proposals[proposalId].escrowId);
    }
}