// SPDX-License-Identifier: UNLICENSED

import './interface/IInvest.sol';
import './interface/IGovernance.sol';


contract LDAOInvest is IInvest {

    address private governanceAddress;

    mapping(address => uint256) private investments;

    function setGovernanceAddress(address addr) external override {
        require(governanceAddress == address(0), "Governance Address Already Set!");
        governanceAddress = addr;
    }

    function invest() external override {
        investments[msg.sender] += msg.value;
        IGovernance gov = IGovernance(governanceAddress);
        gov.registerVoter(msg.sender);
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