// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "./interface/IGovernance.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract LDAOGovernance is IGovernance, AccessControl {
    using Counters for Counters.Counter;
    
    // auth roles
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    // investor contract
    address private investorContractAddress;

    //reward data
    address private rewardTokenAddress;

    // proposal data
    Counters.Counter private proposalCounter;
    uint256 private proposalVotePeriod;
    mapping(uint256 => uint256[]) private proposalVotes;
    mapping(uint256 => mapping(address => uint256)) private proposalUserVotes;
    mapping(uint256 => string) private proposalIPFSHashes;
    mapping(uint256 => uint256) private proposalStartDates;

    constructor(uint256 votePeriod) {
        grantRole(VOTER_ROLE, msg.sender);
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        proposalVotePeriod = votePeriod;
    }

    function setRewardTokenAddress(address tokenAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            rewardTokenAddress == address(0),
            "Reward Token Address Already Set"
        );
        rewardTokenAddress = tokenAddress;
    }

    function setInvestorContractAddress(address contractAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            investorContractAddress == address(0),
            "Investor Contract Address Already Set"
        );
        investorContractAddress = contractAddress;
    }

    function registerVoter(address voterAddress) external override{
        require(
            msg.sender == investorContractAddress,
            "Failed to authenticate sender!"
        );
        grantRole(VOTER_ROLE, voterAddress);
    }

    function createProposal(uint256 startTime, string memory ipfsFolderHash)
        external
        override
        onlyRole(VOTER_ROLE)
        returns (uint256)
    {
        require(
            startTime > block.timestamp,
            "Start Time must not be before current time."
        );
        proposalCounter.increment();
        uint256 index = proposalCounter.current();
        proposalStartDates[index] = block.timestamp;
        proposalIPFSHashes[index] = ipfsFolderHash;
        return index;
    }

    function vote(uint256 proposal, uint256 response)
        external
        override
        onlyRole(VOTER_ROLE)
    {
        require(
            response == 0 || response == 1 || response == 2,
            "Vote Response must be either 0, 1 or 2 (disagree, agree, impartial)"
        );
        require(
            proposalStartDates[proposal] < block.timestamp,
            "Proposal Voting period has not yet started."
        );
        require(
            proposalStartDates[proposal] + proposalVotePeriod > block.timestamp,
            "Proposal Voting period has not yet started."
        );
        proposalUserVotes[proposal][msg.sender] = response;
        proposalVotes[proposal].push(response);
    }
}
