// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { Ownable } from "openzeppelin/access/Ownable.sol";
import { Pausable } from "openzeppelin/security/Pausable.sol";
import { IERC20 } from "openzeppelin/interfaces/IERC20.sol";
import { PDAI } from "./Token.sol";
import { IPool } from "./interfaces/aave-v3/IPool.sol";
import { IWrappedTokenGatewayV3 } from "./interfaces/aave-v3/IWrappedTokenGatewayV3.sol";

/**
 * Lenders can deposit DAI into the pool and receive a pDAI (interest bearing DAI) in return.
 * Subsequently the protocol deposits that amount of DAI inside AAVE Lending Pool to
 * earn interest while waiting for a borrower or the lender to withdraw.
 * Borrowers can deposit ether as collateral and borrow DAI up to 80% of its collateral value.
 * Borrowers can be liquidated when the value of its debt surpasses 80% of its collateral value.
 */
contract Pound is Ownable, Pausable {
  error NotEnoughShares();
  error EmptyCollateral();

  IPool private constant aaveV3Pool =
    IPool(0x794a61358D6845594F94dc1DB02A252b5b4814aD);
  IWrappedTokenGatewayV3 private constant aaveWETHGateway =
    IWrappedTokenGatewayV3(0x1e4b7A6b903680eab0c5dAbcb8fD429cD2a9598c);
  IERC20 private constant dai =
    IERC20(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063);
  IERC20 private constant weth =
    IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);

  PDAI private immutable pDai;

  mapping(address => uint256) private supplied;
  mapping(address => uint256) private borrowed;

  uint256 public totalBorrowed;
  uint256 public totalSupplied;
  uint256 public totalReserved;

  constructor(PDAI _pDai) {
    pDai = _pDai;
  }

  /**
   * @dev Allows lenders to supply DAI and receive pDAI tokens.
   * Deposits supplied amount of DAI to AAVE pool.
   * Lender needs to approve the same amount of DAI for
   * the contract be able to spend that DAI.
   */
  function supply(uint256 _amount) external whenNotPaused {
    dai.transferFrom(msg.sender, address(this), _amount);
    totalSupplied += _amount;
    _depositDAIToAave(_amount);
    uint256 shares = _amount * _getExchangeRate();
    pDai.mint(msg.sender, shares);
  }

  /**
   * @dev Allows lenders to withdraw previosly supplied amount of
   * DAI and burns the corresponding amount pDAI tokens.
   * Withdraws supplied amount of DAI from AAVE pool.
   */
  function withdraw(uint256 _shares) external whenNotPaused {
    if (_shares > pDai.balanceOf(msg.sender)) {
      revert NotEnoughShares();
    }
    uint256 amount = _shares * _getExchangeRate();
    totalSupplied -= amount;
    pDai.burn(_shares);
    _withdrawDAIFromAave(amount);
  }

  function addCollateral() external payable whenNotPaused {
    if (msg.value == 0) {
      revert EmptyCollateral();
    }
    supplied[msg.sender] += msg.value;
    totalSupplied += msg.value;
    _depositWETHToAave(msg.value);
  }

  function removeCollateral(uint256 _amount) external whenNotPaused {}

  function borrow(uint256 _amount) external whenNotPaused {}

  function repay(uint256 _amount) external whenNotPaused {}

  function _depositWETHToAave(uint256 _amount) private {
    aaveWETHGateway.depositETH{value: _amount}(address(aaveV3Pool), address(this), 0);
  }

  function _withdrawWETHFromAave(uint256 _amount) private {

  }

  function _depositDAIToAave(uint256 _amount) private {
    dai.approve(address(aaveV3Pool), _amount);
    aaveV3Pool.deposit(address(dai), _amount, address(this), 0);
  }

  function _withdrawDAIFromAave(uint256 _amount) private {
    aaveV3Pool.withdraw(address(dai), _amount, msg.sender);
  }

  function _getExchangeRate() private pure returns (uint256) {
    return 1;
  }
}
