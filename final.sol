// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PapiGo {
    IERC20 private tether;
    mapping(address => uint) public balancesUSDT;  // Mapping that stores and allows checking balances in USDT
    mapping(address => uint) public loyaltyLevels; // Mapping to store loyalty levels of senders
    address public intermediary; // intermediary 
    
    event Transaction(address indexed sender, address indexed recipient, uint amount, string currency);

    constructor() {
        tether = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // Tether address
    }
    
    function setIntermediary(address _intermediary) external {
        require(_intermediary != address(0), "Invalid intermediary address");
        intermediary = _intermediary; // Set the intermediary address 
    }
    
    function setLoyaltyLevel(address account, uint level) external {
        require(level >= 1 && level <= 5, "Invalid loyalty level");
        loyaltyLevels[account] = level; // Set the loyalty level of an account
    }

    function payTrip(address sender, address recipient, uint amountUSDT) external {
        require(intermediary != address(0), "Intermediary address not set"); 
        
        uint loyaltyLevel = loyaltyLevels[sender];
        uint loyaltyReward = (amountUSDT * loyaltyLevel) / 100; // Calculate loyalty reward based on loyalty level
        
        uint intermediaryFee = (amountUSDT * 10) / 100; // 10% intermediary fee
        uint amountAfterFee = amountUSDT - intermediaryFee; // Deduct intermediary fee from the amount
        
        balancesUSDT[sender] -= amountUSDT;  // Deduct sent amount from sender's balance
        balancesUSDT[intermediary] += intermediaryFee - loyaltyReward; // Add intermediary fee (minus loyalty reward) to intermediary's balance
        balancesUSDT[recipient] += amountAfterFee; // Add amount after fee to recipient's balance
        balancesUSDT[sender] += loyaltyReward; // Add loyalty reward to sender's balance
        
        emit Transaction(sender, recipient, amountUSDT, "USDT");
        emit Transaction(sender, intermediary, intermediaryFee - loyaltyReward, "USDT"); // emit additional transaction for intermediary fee (minus loyalty reward) --> transparency
        emit Transaction(address(0), sender, loyaltyReward, "USDT"); // emit additional transaction for loyalty reward
    }

    function setInitialBalance(address account, uint amountUSDT) external {
        // set initial balance of account
        balancesUSDT[account] = amountUSDT;
    }
}
