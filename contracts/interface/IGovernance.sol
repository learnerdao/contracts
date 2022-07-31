// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

interface IGovernance {
    function setRewardTokenAddress(address tokenAddress) external;

    function setInvestorContractAddress(address contractAddress) external;

    function registerVoter(address voterAddress) external;
    function canVote(address voter) external view returns(bool);
    function vote(uint256 proposal, uint256 vote) external;
    function hasVoted(uint256 proposal, address voter) external view returns(bool);
    function getVote(uint256 proposal, address voter) external view returns(uint);


    function createProposal(uint256 startTime, string memory ipfsFolderHash) external;
    function getProposalVotes(uint256 proposal) external view returns(uint256[] memory);
    function getProposalOutcome(uint256 proposal) external view returns (uint256, uint256, uint256);
    function getProposalFolder(uint256 proposal) external view returns(string memory);
}
