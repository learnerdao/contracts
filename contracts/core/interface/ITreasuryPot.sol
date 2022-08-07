// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITreasuryPot {
    function withdraw(address payable payee, uint256 amount) external;
    function balance() external view returns (uint256);
}