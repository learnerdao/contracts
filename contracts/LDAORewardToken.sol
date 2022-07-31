// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract LDAORewardToken is ERC20 {
    constructor(uint256 supply) ERC20("LDAOReward", "LDAOR") {
        _mint(msg.sender, supply);
    }
}