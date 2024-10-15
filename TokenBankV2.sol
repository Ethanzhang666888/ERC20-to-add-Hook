// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./TokenBank.sol";



// interface BaseERC20 {

//         function balanceOf(address _owner) external  view returns (uint256 balance) ;
//         function transfer(address _to, uint256 _value) external  returns (bool success) ;
//         function transferFrom(address _from, address _to, uint256 _value) external  returns (bool success) ;

// }

interface ITokenReceiver {
    function tokensReceived(address sender, uint256 amount) external;
} 

contract BaseERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 
    uint256 public totalSupply; 

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10 ** decimals;
        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        balance = balances[_owner];
        return balance;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        allowances[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        remaining = allowances[_owner][_spender];
        return remaining;
    }


    function transferWithCallback(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        if (isContract(_to)) {
            ITokenReceiver(_to).tokensReceived(msg.sender, _value);
        }

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}

/////////////////////////////////////////////////////////////////

contract TokenBank {

    BaseERC20 public token;
    mapping(address => uint256) internal  balances;

    constructor(address _tokenAddress) {
        token = BaseERC20(_tokenAddress);
    }

        function deposit(uint256 _amount) public returns (bool) {
        require(_amount > 0, "Amount must be greater than 0");
        
        require(token.transferFrom(msg.sender, address(this), _amount),"fff ");

        balances[msg.sender] += _amount;

        return true;
    }

    function withdraw(uint256 _amount) public returns (bool) {

        require(_amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        require(token.transfer(msg.sender, _amount),"fff");

        return true;
    }

    function balanceOf(address user) public view returns (uint256) {
        return balances[user];
    }

}

contract TokenBankV2 is TokenBank {

    constructor(address _tokenAddress) TokenBank(_tokenAddress) {}

    // Implementing the tokensReceived function to handle the hook from BaseERC20
    function tokensReceived(address _from, uint256 _value) public  {
        require(_value > 0, "Amount must be greater than 0");
        balances[_from] += _value;
    
    }
 
}

