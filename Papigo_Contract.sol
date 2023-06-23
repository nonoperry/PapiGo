// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PapiGo {
    IERC20 private tether;
    mapping(address => uint) public balancesUSDT;  // Mapping that stores and allows to check balances in USDT
    address public intermediary; // intermediary 
    
    event Transaction(address indexed sender, address indexed recipient, uint amount, string currency);

    constructor() {
        tether = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // Tether address
    }
    
    function setIntermediary(address _intermediary) external {
        require(_intermediary != address(0), "Invalid intermediary address");
        intermediary = _intermediary; // Set the intermediary address 
    }

    function payTrip(address sender, address recipient, uint amountUSDT) external {
        require(intermediary != address(0), "Intermediary address not set");
        
        uint intermediaryFee = (amountUSDT * 5) / 100; // 5% intermediary fee
        uint amountAfterFee = amountUSDT - intermediaryFee; // Deduct intermediary fee from amount
        
        balancesUSDT[sender] -= amountUSDT;  // Deduct sent amount from sender balance
        balancesUSDT[intermediary] += intermediaryFee; // Add intermediary fee to intermediary balance
        balancesUSDT[recipient] += amountAfterFee; // Add amount after fee to recipient's balance
        
        emit Transaction(sender, recipient, amountUSDT, "USDT");
        emit Transaction(sender, intermediary, intermediaryFee, "USDT"); // emit additional transaction for intermediary fee --> transparence
    }

    function setInitialBalance(address account, uint amountUSDT) external {
        // set initial balance of account
        balancesUSDT[account] = amountUSDT;
    }
}
