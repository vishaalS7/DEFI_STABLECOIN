// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/*
 * @title : DecentralisedStableCoin
 * author : @0Glitchx
 * collateral : Exogenous collateral (ETH & BTC)
 * minting : Algorithmic
 * Relative stability : pegged to USD
 *
 * this is the contract meant to be governed by DSCengine. this contract is just the ERC20 implementation of of stablCoin system
 *
 */

contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    error DecentralizedStableCoin_MustBeMoreThanZero(); // error for when amount is less than or equal to zero
    error DecentralizedStableCoin_BurnAmountExceedsBalance();
    error DecentralizedStableCoin_NotZeroAddress();

    /**
     * @dev Constructor initializes the ERC20 token with a name and symbol.
     */
    constructor(address initialOwner) ERC20("DecentralizedStableCoin", "0G") Ownable(initialOwner) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DecentralizedStableCoin_MustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert DecentralizedStableCoin_BurnAmountExceedsBalance();
        }
        super.burn(_amount); //Call the parent contract's burn function
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool success) {
        if (_to == address(0)) {
            revert DecentralizedStableCoin_NotZeroAddress();
        }
        if (_amount <= 0) {
            revert DecentralizedStableCoin_MustBeMoreThanZero();
        }
        _mint(_to, _amount); //Call the internal mint function
        return true;
    }
}
