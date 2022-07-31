// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

interface IGovernance {
    function setRewardTokenAddress(address tokenAddress) external;

    function setInvestorContractAddress(address contractAddress) external;

    function registerVoter(address voterAddress) external;

    function vote(uint256 proposal, uint256 vote) external;

    function createProposal(uint256 startTime, string memory ipfsFolderHash)
        external
        returns (uint256);
}
