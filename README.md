# Ethernaut CTF Solutions
code and question prompt can be found under the corresponding files

### 1.Fallback
 Explanation:
 
 * As the name indicates, fallback function is used to serve as a 'fallback' solution for receiving ether when
 the sender do not know your ABI. Typically, it is called when a non-existent function is called on the contract.
 It has no argument, nor name. Most importantly, it requires "payable" marker. Because of fallback function's public nature, 
 it opens up a backdoor for outside world. When the fallback function involves logic of changin the ownership, it could be
 a recipe for disaster. This is exactly what's going on here.  

 Solution:
	
  * To change the ownership of the contract, we should take a look at the fallback function itself: 	 
  
 		  require(msg.value > 0 && contributions[msg.sender] > 0);
      
 	* this line here requires two conditions: 
 		* 1) the function call needs to has some value;
 		* 2) the sender address needs to be stored in the contributions map already when the call initiates.
  	
  * To achieve this, we can call the contribute() function in the console with an arbitrary value larger than 0.001 ether,
 	then we can transfer and arbitrary amount again to claim the ownership. To reduce its balance to zero, we can simply use
 	contract.withdraw().
