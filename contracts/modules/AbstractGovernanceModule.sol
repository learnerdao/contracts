// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interface/IGovernanceModule.sol";
import "../core/interface/IGovernanceCore.sol";

abstract contract AbstractGovernanceModule is IGovernanceModule {
    address internal _governanceCoreAddress;
    mapping(uint256 => IGovernanceModule.ProposalData) internal _proposalDatas;

    function setGovernanceCore(address governanceCore) external  {
        require(_governanceCoreAddress == address(0), "Governance Core Contract already set.");
        _governanceCoreAddress = governanceCore;
    }

    function _getGovernanceCore() internal view returns(IGovernanceCore) {
        return IGovernanceCore(_governanceCoreAddress);
    }

    function _createProposalId() internal returns (uint256) {
        return _getGovernanceCore().createProposal(address(this));
    }

    function _saveProposal(string memory title) internal returns (uint256){
        uint256 id = _createProposalId();
        ProposalData storage data = _proposalDatas[id];
        data.creator = msg.sender;
        data.title = title;
        data.module = address(this);
        return id;
    }

    function getData(uint256 proposalId)
        external
        view
        override
        returns (ProposalData memory)
    {
        return _proposalDatas[proposalId];
    }
}
