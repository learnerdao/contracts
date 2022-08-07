// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IGovernanceModule {
    struct ProposalData {
        string title;
        address creator;
        address module;
    }

    function getData(uint256 proposalId) external view returns(ProposalData memory);
    function execute(uint256 proposalId) external;
}