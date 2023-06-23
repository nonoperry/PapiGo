// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PapiGo {
    IERC20 private tether;
    mapping(address => uint) public balancesUSDT;  // Mapping to store balances in USDT, also allows to check balances
    
    event Transaction(address indexed sender, address indexed recipient, uint amount, string currency);

    constructor() {
        tether = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // Tether address
    }

    function payTrip(address sender, address recipient, uint amountUSDT) external {
        // Payment function
        balancesUSDT[sender] -= amountUSDT;  // Deduct the sent amount from the sender's balance
        balancesUSDT[recipient] += amountUSDT; // Add sent amount from the sender's balance
        emit Transaction(sender, recipient, amountUSDT, "USDT");
    }

    function setInitialBalance(address account, uint amountUSDT) external {
        // Function to set the initial balance of an account
        balancesUSDT[account] = amountUSDT;
    }
}
