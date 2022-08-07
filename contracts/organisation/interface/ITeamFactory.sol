// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITeamFactory {
    function setTreasuryAddress(address addr) external;

    function deployTeam(string memory name) external;
    
    function enumerateTeams() external view returns(address[] memory);
}
