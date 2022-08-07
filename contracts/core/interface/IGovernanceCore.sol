// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IGovernanceCore {
    struct ProposalLog {
        address module;
        uint256 proposalId;
    }

    function createProposal(address creatorModule) external returns (uint256);

    function getProposalTitle(uint256 proposalId) external view returns (string memory);
    function registerGovernanceModule(address module) external;
    function replaceRegistrarModule(address newModule) external;
}
