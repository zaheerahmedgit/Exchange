// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ierc20 {
    function totalSupply() external view returns(uint);
    function balanceOf(address tokenOwner) external view returns(uint balance);
    function transfer(address to, uint tokens) external returns(bool success);
    function allowance(address tokenOwner, address spender) external view returns(uint tokens);
    function approve(address spender, uint tokens) external returns(bool success);
    function transferFrom(address from, address to, uint tokens) external returns(bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ABXToken is ierc20{
    string public name = "ABX Token";
    string public symbol = "ABXT";
    uint8 public decimals = 18; 
    uint public totalSupply;
    address public owner;

    mapping(address=>uint) public balances;
    mapping(address=>mapping(address=>uint)) allowed;


    constructor () {
        totalSupply = 5000000;
        owner = msg.sender;
        balances[owner] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns(bool success){
        require(balances[msg.sender]>tokens, "balance kam hai");
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public override returns(bool success){
        require(balances[msg.sender]>tokens, "allow ni kar sakta");
        require(tokens>0, "token hi kam hai yar");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns(uint tokens){
        return allowed[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint tokens) public override returns(bool success){
        require(allowed[from][to]>=tokens, "allow hi nahi hai");
        require(balances[from]>=tokens, "balance kam hai");
        balances[from] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
}