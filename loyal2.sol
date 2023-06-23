// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PapiGo {
    IERC20 private tether;
    mapping(address => uint) public balancesUSDT;  // Mapping to store balances in USDT, also allows to check balances
    mapping(address => uint) public loyaltyLevels;  // Mapping to store loyalty levels

    event Transaction(address indexed sender, address indexed recipient, uint amount, string currency);

    constructor() {
        tether = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // Tether address
    }

    function payTrip(address sender, address recipient, uint amountUSDT) external {
        require(amountUSDT > 0, "Invalid amount");

        uint discountPercent = loyaltyLevels[sender];
        uint discountAmount = (amountUSDT * discountPercent) / 100;
        uint payableAmount = amountUSDT - discountAmount;

        require(balancesUSDT[sender] >= payableAmount, "Insufficient balance");

        balancesUSDT[sender] -= payableAmount;  // Deduct the payable amount from the sender's balance
        balancesUSDT[recipient] += amountUSDT; // Add the original amount to the recipient's balance

        emit Transaction(sender, recipient, payableAmount, "USDT");
    }

    function setInitialBalance(address account, uint amountUSDT) external {
        require(amountUSDT >= 0, "Invalid amount");
        balancesUSDT[account] = amountUSDT;
    }

    function setLoyaltyLevel(address account, uint level) external {
        require(level >= 1 && level <= 10, "Invalid loyalty level");
        loyaltyLevels[account] = level;
    }
}
