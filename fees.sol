// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PapiGo {
    IERC20 private tether;
    mapping(address => uint) public balancesUSDT;  // Mapping that stores and allows to check balances in USDT
    mapping(address => uint) public loyaltyLevels; // Mapping to store loyalty levels of addresses
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
        loyaltyLevels[account] = level; // Set the loyalty level for an account
    }

    function calculateIntermediaryFee(uint amountUSDT, uint loyaltyLevel) internal pure returns (uint) {
        uint baseFee = 10 - loyaltyLevel; // base fee based on loyalty level
        return (amountUSDT * baseFee) / 100; // intermediary fee as percentage
    }

    function payTrip(address sender, address recipient, uint amountUSDT) external {
        require(intermediary != address(0), "Intermediary address not set");
        
        uint loyaltyLevel = loyaltyLevels[sender]; // Get the loyalty level of sender
        uint intermediaryFee = calculateIntermediaryFee(amountUSDT, loyaltyLevel); // intermediary fee based on loyalty level
        uint amountAfterFee = amountUSDT - intermediaryFee; // Deduct intermediary fee from amount
        
        balancesUSDT[sender] -= amountUSDT;  // Deduct sent amount from sender balance
        balancesUSDT[intermediary] += intermediaryFee; // Add intermediary fee to intermediary balance
        balancesUSDT[recipient] += amountAfterFee; // Add amount after fee to recipient's balance
        
        emit Transaction(sender, recipient, amountUSDT, "USDT");
        emit Transaction(sender, intermediary, intermediaryFee, "USDT"); // emit additional transaction for intermediary fee --> transparency
    }

    function setInitialBalance(address account, uint amountUSDT) external {
        // set initial balance of account
        balancesUSDT[account] = amountUSDT;
    }
}
