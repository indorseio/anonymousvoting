pragma solidity ^0.4.11;

import './ERC20.sol';
import "./SafeMath.sol";
import "./Ownable.sol";


contract SCRToken is ERC20, SafeMath, Ownable {

   // metadata
    string  public constant name = "Indorse SCR Token";
    string  public constant symbol = "SCR";
    uint256 public constant decimals = 1;
    string  public version = "1.0";

    uint256 public totalSupply;

    mapping(address => uint256) balances;

    address public crowdSale;
    address public indorsePlatform;


    function setHost(address _indorsePlatform) onlyOwner {
        indorsePlatform = _indorsePlatform;
    }

    // @dev hijack this function to set crowdsale address
    // 
    function allowance(address , address ) constant returns (uint) {
        return 0;
    }
    
    
    function approve(address _crowdSale , uint256) onlyOwner returns (bool ok)  {
        crowdSale       = _crowdSale;
        return true;
    }

    function transfer(address , uint256 ) returns (bool) {
        assert(false);
    }
    
    function transferFrom(address from, address to, uint256 value) returns (bool) {
        if (from==0x0) mintToken(to,value);
        else if (to == 0x0) burnToken(from,value);
        else return false;
        return true;
    }


    function mintToken(address who, uint256 value) internal {
        require((msg.sender==crowdSale) || (msg.sender == indorsePlatform));
        require(who != 0x0);
        balances[who] = safeAdd(balances[who],value);
        totalSupply   = safeAdd(totalSupply,value);
        Transfer(0x0,who,value);
    }

    function burnToken(address who, uint256 value) internal{
        require(msg.sender == indorsePlatform);
        require (who != 0x0);
        uint256 limitedVal  = (value > balances[who]) ?  balances[who] : value;
        balances[who] = safeSubtract( balances[who],limitedVal);
        totalSupply = safeSubtract(totalSupply,limitedVal);
        Transfer(who,0x0,limitedVal);
    }

    function balanceOf(address who) constant returns (uint256) {
        return balances[who];
    }
}