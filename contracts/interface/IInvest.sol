// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

interface IInvest {
    function setGovernanceAddress(address addr) external;

    function setRewardTokenAddress(address tokenAddress) external;

    function invest() external payable;

    function getInvestmentByAddress(address investor)
        external
        view
        returns (uint256);
}
