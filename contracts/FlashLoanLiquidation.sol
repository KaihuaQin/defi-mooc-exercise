//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.6;

import "hardhat/console.sol";

interface IFlashLoanReceiver {
  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external returns (bool);
}

interface ILendingPool {
  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;

  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;
}


contract FlashLoanLiquidation is IFlashLoanReceiver {
  ILendingPool lendingPool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

  function run(bytes calldata params) external {
    (address[] memory assets, uint256[] memory amounts, uint256[] memory modes, bytes memory params) = abi.decode(params, (address[], uint256[], uint256[], bytes));
    lendingPool.flashLoan(address(this), assets, amounts, modes, address(this), params, 0);
  }

  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external override returns (bool) {
    (address collateralAsset, address debtAsset, address user, uint256 debtToCover) = abi.decode(params, (address, address, address, uint256));
    lendingPool.liquidationCall(collateralAsset, debtAsset, user, debtToCover, false);
    return true;
  }
}
