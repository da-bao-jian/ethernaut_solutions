# Ethernaut CTF Solutions
code and question prompts can be found under the corresponding files

### 1.Fallback
 Explanation:
 
 * As the name indicates, fallback function is used to serve as a 'fallback' solution for receiving ether when
 the sender do not know your ABI. Typically, it is called when a non-existent function is called on the contract.
 It has no argument, nor name. Most importantly, it requires a "payable" marker. Because of fallback function's public nature, 
 it could open up a backdoor for the outside world. When the fallback function involves logic of changin the ownership, it could be
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

### 2. Fallout
Exaplanation:

* There's a typo in the contract constructor.

Solution:

 * In the console, simply create an instance of the contract. 

### 3.Coin Flip
Explanation:

* In this problem, the source of randomness depends on the blockhash of the previous block and a fixed variable 'FACTOR', which are obtained by:
	    
	    uint256 blockValue = uint256(blockhash(block.number.sub(1)));
	    uint256 coinFlip = blockValue.div(FACTOR);
	    
* However, blockhash of the previous block and FACTOR are easily assesible from another contract because the flip() function includes both. 

Solution:

* To exploit the vulnerability, we can write an attack contract that get an instance of the CoinFlip contract and use the flip() function with the same input variables. Since the attacking contract will be using the same blockhash and FACTOR, it could correctly predict the outcome of the flip.

### 4. Telephone
Explanation:
 * tx.origin is the original address that initiated the transaction while msg.sender is the most immediate contract/EOA. To change the address of the contract, the attacker can crreate a contract that calls `changeOwner` function. In this case, msg.sender would be the attacking contract whereas tx.origin would be the attacker's address. 

Solution:
 * Write an attacking contract that calls Telephone's `changeOwner` function. 

### 5. Token
Explanation:
 * Solidity can handle up to 256 bit numbers (up to 2²⁵⁶-1), so incrementing 2**256-1 by 1 would result into 0. Conversely, decrementing 0 by 1 would result into 2**256-1. 

Solution:
 * In the console, call the `transfer()` function with a random address and 21 to cause underflow. 
