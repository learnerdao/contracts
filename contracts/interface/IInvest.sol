// SPDX-License-Identifier: UNLICENSED

interface IInvest {
    function setGovernanceAddress(address addr) external;

    function invest() external;
    function getInvestmentByAddress(address investor) external view returns(uint256);

}