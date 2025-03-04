// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStakeX is IERC20 {
    function decimals() external view returns (uint8);

    function mint(address account, uint256 amount) external;
}
