// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITeamFactory {
    function setTreasuryAddress(address addr) external;

    function deployTeam(string memory name) external;
    
    function enumerateTeams() external view returns(address[] memory);
    function teamFromId(uint256 id) external view returns(address);
    function getTeamPrimaryPotBalance(address team) external view returns (uint256);
}
