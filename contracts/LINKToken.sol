//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LINKToken is ERC20 {
  constructor(uint initialSupply) ERC20("LINKToken", "LINK") {
    _mint(msg.sender, initialSupply);
  }
}