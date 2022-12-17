// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Aave lending contract that we need to
// interact in order to send the deposits and collaterals.
interface IPool {
  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);
}
