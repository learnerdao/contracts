// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '../core/interface/IVoteToken.sol';

contract LDAOTokenDistributionMarket {
    address private _tokenAddress;
    address payable private _treasuryAddress;

    constructor(address tokenAddress, address payable treasuryAddress) {
        _tokenAddress = tokenAddress;
        _treasuryAddress = treasuryAddress;
    }

    function buy() public payable {
        IVoteToken tok = IVoteToken(_tokenAddress);
        tok.mint(msg.sender, msg.value);
        _treasuryAddress.transfer(msg.value);
    }
}