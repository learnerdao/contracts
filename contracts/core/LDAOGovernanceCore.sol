// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interface/IGovernanceCore.sol";
import "../modules/interface/IGovernanceModule.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract LDAOGovernanceCore is IGovernanceCore {
    using Counters for Counters.Counter;


    address private _moduleRegistrarAddress;

    constructor(address moduleRegistrar) {
        _moduleRegistrarAddress = moduleRegistrar;
    }

    event ProposalCreated(address module, uint256 proposalId);

    Counters.Counter private _proposalCounter;
    mapping(uint256 => ProposalLog) private _proposals;

    mapping(address => bool) private _allowedModules;

    function createProposal(address creatorModule)
        external
        override
        returns (uint256)
    {
        require(
            creatorModule == msg.sender,
            "Mismatch in Governance Module address passed in and caller contract address. Possible malicious call!"
        );
        require(
            _allowedModules[msg.sender] == true,
            "Governance Module Contract not registered with Governance Core Contract"
        );
        require(
            _allowedModules[creatorModule] == true,
            "Governance Module Contract not registered with Governance Core Contract"
        );

        uint256 index = _proposalCounter.current();
        ProposalLog storage proposal = _proposals[index];
        proposal.module = creatorModule;
        proposal.proposalId = index;

        _proposalCounter.increment();

        emit ProposalCreated(creatorModule, index);

        return index;
    }

    function getProposalTitle(uint256 proposalId)
        external
        view
        override
        returns (string memory)
    {
        ProposalLog storage proposal = _proposals[proposalId];
        IGovernanceModule sideModule = IGovernanceModule(proposal.module);
        IGovernanceModule.ProposalData memory data = sideModule.getData(
            proposalId
        );
        return data.title;
    }

    function registerGovernanceModule(address module) external override {
        require(msg.sender == _moduleRegistrarAddress);
        _allowedModules[module] = true;
    }

    function replaceRegistrarModule(address newModule) external override {
        require(msg.sender == _moduleRegistrarAddress);
        _moduleRegistrarAddress = newModule;
    }
}
