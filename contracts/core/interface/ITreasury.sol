// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITreasury {
    function deployFundingPot() external returns(uint256);
    function addFundsHandler(address handler) external;
    function withdrawToAddress(address payable payee, uint256 pot) external;
    function moveFunds(uint256 potFrom, uint256 potTo, uint256 amount) external;
    function allocateFunds(uint256 potTo, uint256 amount) external;
    function getAllocationForPot(uint256 pot) external view returns(uint256);
    function getTotalAllocation() external view returns (uint256);
    function getUnallocatedFunds() external view returns (uint256);
    function escrowFunds(uint256 from, uint256 to, uint256 amount) external returns (uint256);
    function escrowFundsFromTreasury(uint256 to, uint256 amount) external returns (uint256);
    function releaseFunds(uint256 escrowId) external;
}