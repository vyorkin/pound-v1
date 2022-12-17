// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { ERC20 } from "openzeppelin/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";

contract PDAI is ERC20, ERC20Burnable {
  constructor() ERC20("Pound DAI", "pDAI") {}

  function mint(address _to, uint256 _amount) public {
    _mint(_to, _amount);
  }
}
