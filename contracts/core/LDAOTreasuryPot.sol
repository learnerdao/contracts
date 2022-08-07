// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import './interface/ITreasuryPot.sol';

contract LDAOTreasuryPot is AccessControl, ITreasuryPot {
    bytes32 public constant FUNDS_HANDLER_ROLE =
        keccak256("FUNDS_HANDLER_ROLE");

    constructor(address treasuryRootAddress) {
        _grantRole(FUNDS_HANDLER_ROLE, treasuryRootAddress);
    }

    function withdraw(address payable payee, uint256 amount)
        public
        onlyRole(FUNDS_HANDLER_ROLE)
    {
        require(
            address(this).balance >= amount,
            "Insufficent Funds for withdrawal."
        );
        payee.transfer(amount);
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }
}
