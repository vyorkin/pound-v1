// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Helper contract to easily wrap and unwrap ETH as necessary when
// interacting with the protocol, since only ERC20 is used within protocol interactions.
interface IWrappedTokenGatewayV3 {
  function depositETH(
    address pool,
    address onBehalfOf,
    uint16 referralCode
  ) external payable;

  function withdrawETH(
    address pool,
    uint256 amount,
    address onBehalfOf
  ) external;
}
