// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITeam {
    function joinTeam(address user) external;

    function leaveTeam(address user) external;

    function assignFundingPot(uint256 pot) external;

    function isMember(address user) external view returns (bool);
}
