// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./USDToken.sol";
import "./ABXToken.sol";

contract Exchange {
    address public owner;
    mapping(address => mapping(address => uint)) public balances;
    mapping(address => bool) public authorizedTokens;
    uint public constant exchangeRate = 5; // 1 USDT = 5 ABXT
    
    event Deposit(address token, address user, uint amount);
    event Withdraw(address token, address user, uint amount);
    event Swap(address tokenFrom, address tokenTo, address user, uint amountFrom, uint amountTo);
    
    USDToken public usdToken;
    ABXToken public abxToken;
    mapping(address => uint) public convertedTokens;
    
    constructor(address _usdToken, address _abxToken) {
        owner = msg.sender;
        usdToken = USDToken(_usdToken);
        abxToken = ABXToken(_abxToken);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "maalik kdhr hai bhai");
        _;  
    }

    function deposit(address token, uint amount) public {
    require(authorizedTokens[token], "Token not authorized");
    require(amount > 0, "Amount must be greater than zero");
    require(token == address(usdToken) || token == address(abxToken), "Invalid token");

    if (token == address(usdToken)) {
        usdToken.transferFrom(msg.sender, address(this), amount);
    } else {
        abxToken.transferFrom(msg.sender, address(this), amount);
    }
    
    balances[token][msg.sender] += amount;
    balances[token][address(this)] += amount; // ✅ Exchange balance update
    emit Deposit(token, msg.sender, amount);
}


    function withdraw(address token, uint amount) public {
        require(balances[token][msg.sender] >= amount, "Insufficient balance");
        balances[token][msg.sender] -= amount;
        
        if (token == address(usdToken)) {
            usdToken.transfer(msg.sender, amount);
        } else {
            abxToken.transfer(msg.sender, amount);
        }
        
        emit Withdraw(token, msg.sender, amount);
    }

    function authorizeToken(address token) public onlyOwner {
        authorizedTokens[token] = true;
    }

    function revokeToken(address token) public onlyOwner {
        authorizedTokens[token] = false;
    }

    function swapTokens(address tokenFrom, address tokenTo, uint amountFrom) public {
    require(
        (tokenFrom == address(usdToken) && tokenTo == address(abxToken)) || 
        (tokenFrom == address(abxToken) && tokenTo == address(usdToken)), 
        "Invalid token pair"
    );
    require(authorizedTokens[tokenFrom] && authorizedTokens[tokenTo], "Tokens not authorized");
    require(balances[tokenFrom][msg.sender] >= amountFrom, "Insufficient token balance");

    uint amountTo;
    if (tokenFrom == address(usdToken)) {
        amountTo = amountFrom * exchangeRate; // 1 USDT = 5 ABXT
        require(balances[tokenTo][address(this)] >= amountTo, "Insufficient liquidity");

        usdToken.transferFrom(msg.sender, address(this), amountFrom);
        abxToken.transfer(msg.sender, amountTo);

        balances[tokenFrom][msg.sender] -= amountFrom;
        balances[tokenFrom][address(this)] += amountFrom; // ✅ Exchange balance update karo
        balances[tokenTo][address(this)] -= amountTo;
        balances[tokenTo][msg.sender] += amountTo;
    } else {
        amountTo = amountFrom / exchangeRate; // 5 ABXT = 1 USDT
        require(balances[tokenTo][address(this)] >= amountTo, "Insufficient liquidity");

        abxToken.transferFrom(msg.sender, address(this), amountFrom);
        usdToken.transfer(msg.sender, amountTo);

        balances[tokenFrom][msg.sender] -= amountFrom;
        balances[tokenFrom][address(this)] += amountFrom; // ✅ Exchange balance update karo
        balances[tokenTo][address(this)] -= amountTo;
        balances[tokenTo][msg.sender] += amountTo;
    }
    
    convertedTokens[msg.sender] += amountTo;
    emit Swap(tokenFrom, tokenTo, msg.sender, amountFrom, amountTo);
}



    function getConvertedTokens(address user) public view returns (uint) {
        return convertedTokens[user];
    }
}
