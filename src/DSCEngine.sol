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

import {DecentralizedStableCoin} from "./DecentralisedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DSC Engine
 * @author 0Glitchx
 *
 * this system is designed to be as minimal as possible, and have the token maintain a 1 token == 1 dollar peg.
 * this stablecoin has the properteis:
 * - exogenous collateral
 * - Dollar Pegged
 * - Algoritmically stable
 *
 * it is similar to DAI if DAI has no governance, no fees, and was only backed by wETH and wBTC
 *
 * our DSC system should always be "overcollatralized". at no point, shoiuld the value of all collateral <= the dollar backed value of all the  DSC.
 *
 * @notice This contract is the core of the DSC system. it handles all the login of mining and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is very loosely based on the makerDAO DSS (DAI) system
 */
contract DSCEngine is ReentrancyGuard {
    error DscEngine_needsMoreThanZero();
    error DscEngine_TokenAddressesAndPriceFeedAddresssMustBeSameLength();
    error DscEngine_NotAllowedToken();
    error DscEngine_TransferFailed();

    DecentralizedStableCoin private immutable i_dsc;

    event collateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DscEngine_needsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DscEngine_NotAllowedToken();
        }
        _;
    }

    constructor(address[] memory tokenAddress, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddress.length != priceFeedAddresses.length) {
            revert DscEngine_TokenAddressesAndPriceFeedAddresssMustBeSameLength();
        }
        for (uint256 i = 0; i <= tokenAddress.length; i++) {
            s_priceFeeds[tokenAddress[i] = priceFeedAddresses[i]];    
        }
        i_dsc = DecentralizedStableCoin(dscAddress); 
    }

    function depositCollateralAndMintDsc() external {}

    /**
     *
     * @param tokenCollateralAddress => the address of the token to deposit as colateral
     * @param amountCollateral  => the amount of collateral to deposit
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit collateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DscEngine_TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquiDate() external {}

    function getHealthFactor() external view {}
}
