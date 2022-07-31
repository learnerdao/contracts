// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import './interface/IInvest.sol';
import './interface/IGovernance.sol';
import "@openzeppelin/contracts/access/AccessControl.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract LDAOInvest is IInvest, AccessControl {
    constructor() {
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    address private governanceAddress;
    address private rewardTokenAddress;
    mapping(address => uint256) private investments;

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

    function setGovernanceAddress(address addr) external override {
        require(governanceAddress == address(0), "Governance Address Already Set!");
        governanceAddress = addr;
    }

    function invest() external payable override {
        investments[msg.sender] += msg.value;
        IGovernance gov = IGovernance(governanceAddress);
        gov.registerVoter(msg.sender);
        IERC20 reward = IERC20(rewardTokenAddress);
        reward.transfer(msg.sender, msg.value);
    }

    function getInvestmentByAddress(address investor)
        external
        view
        override
        returns (uint256)
    {
        return investments[investor];
    }
}