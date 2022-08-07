// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import './AbstractGovernanceModule.sol';
import '../organisation/interface/ITeamFactory.sol';
import '../organisation/interface/ITeam.sol';
import '../core/interface/ITreasury.sol';

contract LDAOTreasuryTransferBetweenTeams is AbstractGovernanceModule {

    struct ProposedTransfer {
        address teamFrom;
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

    function proposeTeamFundsTransfer(uint256 teamFrom, uint256 teamTo, uint256 amount, string memory title) external returns (uint256) {
        ITeamFactory fac = ITeamFactory(_teamFactory);
        address from = fac.teamFromId(teamFrom);
        address to = fac.teamFromId(teamTo);
        require(fac.getTeamPrimaryPotBalance(from) >= amount, "Transfer amount icannot be larger than team's primary pot balance");
        uint256 proposalId = _saveProposal(title);
        ProposedTransfer storage transfer = _proposals[proposalId];
        transfer.amount = amount;
        transfer.teamFrom = from;
        transfer.teamTo = to;

        uint256 fromPot = ITeam(from).getPrimaryPot();
        uint256 toPot = ITeam(to).getPrimaryPot();
        transfer.escrowId = ITreasury(_treasury).escrowFunds(fromPot, toPot, amount);
    }

    function execute(uint256 proposalId) external override {
        ITreasury(_treasury).releaseFunds(_proposals[proposalId].escrowId);
    }
}