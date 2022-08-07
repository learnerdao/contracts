// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../core/interface/IGovernanceCore.sol";
import "./interface/IGovernanceModule.sol";
import "./AbstractGovernanceModule.sol";

contract LDAOModuleRegistrarV1 is AbstractGovernanceModule {
    struct ProposedModuleUpgrade {
        address old;
        address replacement;
    }

    mapping(uint256 => address) private _proposalModules;
    mapping(uint256 => ProposedModuleUpgrade) private _proposalModuleUpgrades;
    mapping(uint256 => bool) private _proposalIsUpgrade;

    constructor() {}

    function proposeModule(address module, string memory title) external {
        uint256 proposalId = _saveProposal(title);
        _proposalModules[proposalId] = module;
    }

    function proposeRegistrarUpgrade(address replacement, string memory title)
        external
    {
        uint256 proposalId = _saveProposal(title);
        ProposedModuleUpgrade storage replacementData = _proposalModuleUpgrades[
            proposalId
        ];
        replacementData.old = address(this);
        replacementData.replacement = replacement;
        _proposalIsUpgrade[proposalId] = true;
    }

    function execute(uint256 proposalId) external override {
        require(
            msg.sender == _governanceCoreAddress,
            "Only the Core Governance Contract can call this function."
        );
        IGovernanceCore gov = _getGovernanceCore();
        if (_proposalIsUpgrade[proposalId]) {
            gov.replaceRegistrarModule(
                _proposalModuleUpgrades[proposalId].replacement
            );
        } else {
            gov.registerGovernanceModule(_proposalModules[proposalId]);
        }
    }
}
