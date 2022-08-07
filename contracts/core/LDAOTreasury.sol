// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./LDAOTreasuryPot.sol";
import "./interface/ITreasury.sol";

contract LDAOTreasury is AccessControl, ITreasury {
    using Counters for Counters.Counter;

    bytes32 public constant FUNDS_HANDLER_ROLE =
        keccak256("FUNDS_HANDLER_ROLE");

    Counters.Counter private _potIdCounter;
    Counters.Counter private _escrowCounter;

    struct EscrowEntry {
        uint256 from;
        uint256 to;
        uint256 amount;
        bool released;
    }

    address[] private _allFundingPots;
    mapping(uint256 => address payable) private _potAddresses;
    mapping(uint256 => uint256) private _potAddressIndexes;
    uint256 private _escrowPot;
    mapping(uint256 => EscrowEntry) private _escrows;

    constructor(address teamFactory) {
        _grantRole(FUNDS_HANDLER_ROLE, teamFactory);
        _escrowPot = deployFundingPot();
    }

    function deployFundingPot()
        public
        onlyRole(FUNDS_HANDLER_ROLE)
        returns (uint256)
    {
        LDAOTreasuryPot pot = new LDAOTreasuryPot(address(this));
        _potIdCounter.increment();
        uint256 index = _potIdCounter.current();
        _potAddresses[index] = payable(address(pot));
        _allFundingPots.push(address(pot));
        _potAddressIndexes[index] = _allFundingPots.length - 1;
        return index;
    }

    function escrowFunds(
        uint256 from,
        uint256 to,
        uint256 amount
    ) external override onlyRole(FUNDS_HANDLER_ROLE) returns (uint256) {
        moveFunds(from, _escrowPot, amount);
        uint256 index = _escrowCounter.current();
        _escrowCounter.increment();
        EscrowEntry storage escrow = _escrows[index];
        escrow.released = false;
        escrow.from = from;
        escrow.to = to;
        escrow.amount = amount;
        return index;
    }

    function releaseFunds(uint256 escrowId) external override {
        EscrowEntry storage escrow = _escrows[escrowId];
        escrow.released = true;
        moveFunds(_escrowPot, escrow.to, escrow.amount);
    }

    function addFundsHandler(address handler)
        public
        onlyRole(FUNDS_HANDLER_ROLE)
    {
        _grantRole(FUNDS_HANDLER_ROLE, handler);
    }

    function withdrawToAddress(address payable payee, uint256 pot)
        public
        onlyRole(FUNDS_HANDLER_ROLE)
    {
        LDAOTreasuryPot tpot = LDAOTreasuryPot(_potAddresses[pot]);
        tpot.withdraw(payee, pot);
    }

    function moveFunds(
        uint256 potFrom,
        uint256 potTo,
        uint256 amount
    ) public onlyRole(FUNDS_HANDLER_ROLE) {
        LDAOTreasuryPot tpot = LDAOTreasuryPot(_potAddresses[potFrom]);
        address payable toAddress = _potAddresses[potTo];
        tpot.withdraw(toAddress, amount);
    }

    function allocateFunds(uint256 potTo, uint256 amount)
        public
        onlyRole(FUNDS_HANDLER_ROLE)
    {
        require(
            address(this).balance >= amount,
            "Insufficent Funds for allocation."
        );
        address payable addr = _potAddresses[potTo];
        addr.transfer(amount);
    }

    function getAllocationForPot(uint256 pot) public view returns (uint256) {
        LDAOTreasuryPot tpot = LDAOTreasuryPot(_potAddresses[pot]);
        return tpot.balance();
    }

    function getTotalAllocation() public view returns (uint256) {
        uint256 bal = 0;
        for (uint256 i = 0; i < _allFundingPots.length; i++) {
            bal += LDAOTreasuryPot(_allFundingPots[i]).balance();
        }
        return bal;
    }

    function getUnallocatedFunds() public view returns (uint256) {
        return address(this).balance;
    }

    function escrowFundsFromTreasury(uint256 to, uint256 amount)
        external
        override
        returns (uint256)
    {
        allocateFunds(_escrowPot, amount);
        uint256 index = _escrowCounter.current();
        _escrowCounter.increment();
        EscrowEntry storage escrow = _escrows[index];
        escrow.released = false;
        escrow.to = to;
        escrow.amount = amount;
        return index;
    }
}
