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
 * Solidity can handle up to 256 bit numbers (up to 2²⁵⁶-1), so incrementing 2^256-1 by 1 would result into 0. Conversely, decrementing 0 by 1 would result into 2^256-1. 

Solution:
 * In the console, call the `transfer()` function with a random address and 21 to cause underflow. 

 ### 6. Delegation
 Explanation:
  * `delegatecall` is a low level function similar to `call`. The difference is that when a contract `delegatecall` another contract, the storage used ties to the calling contract. For instance, if a contract caller calls contract A, and contract A executes `delegatecall` to contract B, `msg.sender` in B would still point to the contract A caller. `delegatecall` is useful for updating intermediary contract's state after contract being depoyed onto the Etheruem network, yet it leaves the backdoor open for malicious attacks, especailly coupled with poorly written fallback functions. 

  Solution:
  * Here, we can use `web3.utils.keccak256` to hash the `pwn()` function in the console, and pack the hashing result into the `sendTransaction` function as the value for `data` key. This way, we are able to trigger the fallback function in `Delegation` with function selector of `pwn()`. Because `pwn()` updates the owner to `msg.sender` and `Delegation` uses `delegatecall` in its fallback function, `Delegation`'s owner will be updated to the attacker. 

 Best Practice:
  * Usage of delegatecall is particularly risky and has been used as an attack vector on multiple historic hacks. With it, your contract is practically saying "here, -other contract- or -other library-, do whatever you want with my state". Delegates have complete access to your contract's state. The delegatecall function is a powerful feature, but a dangerous one, and must be used with extreme care.

### 7. Force
Explanation:
 * Normally, to send ether to a contract, the contract requires functions with `payable` keywords. However, there are exceptions. One can forcefully send ether with `selfdestruct`.  

 Solution:
  * Create a contract in remix IDE and add some value to it. Then, wrtie a function to call `selfdestruct` on the contract instance's address. 

Best Practice:
* In solidity, for a contract to be able to receive ether, the fallback function must be marked 'payable'.
However, there is no way to stop an attacker from sending ether to a contract by self destroying. Hence, it is important not to count on the invariant address(this).balance == 0 for any contract logic.

### 8. Vault
Explanation:
 * Data is stored sequentially for each contract in the order of execution. For variables that are smaller than 32 bytes, they will occupy one slot until all 32 bytes are filled, otherwise, seperate slots are allocated. Here, `password` is a 32 bytes private varialbe, therefore it occupies the second slot allocated for `Vault`. It's worth noting that even though it is marked with `private`, it does not mean it is not visible on the network. 

 Solution:
  * To access `password`'s value, we can use ```web3.eth.getStorageAt``` method for index position 1. 

  Best Practice:
   * Always hash the password!

### 9. King
Explanation:
 * To prevent the reclaim of throne, we need to make sure that the `transfer` won't go through successfully. To deliberately make a transaction fail, one can either omit the fallback function, or write a fallback function that automatically revert any transaction

 Solution:
  * First, we need ot claim the kingship by sending an ether that's larger than the current prize value. Then, we can either omit the fallback function, or write one that simply revert any incoming transactions.

### 10. Re-Entrance
Explanation:
 * Re-entrance happens when the stack invoke the subroutines before returning the original execution. In the context of solidity, calling a malicious fallback function could result in recursion that could withdraw all of the fund in the contract. It's better explained [here](https://quantstamp.com/blog/what-is-a-re-entrancy-attack)

 Solution:
  * Here, we can write an attacking contract that deposit some ether into the victim contract to initialize its value in the `balance` mapping. Then, to deplete the contract balance, we call the `withdraw` method in attacking contract's fallback function to create the re-rentrance recursion. 
Best Practice:
 * Avoid using `call` or `transfer` as they can break contracts. Use [Checks-effects-interations pattern](https://docs.soliditylang.org/en/develop/security-considerations.html#use-the-checks-effects-interactions-pattern), [Reentrancy Guard](https://docs.openzeppelin.com/contracts/2.x/api/utils#ReentrancyGuard), or [PullPaymen](https://blog.openzeppelin.com/15-lines-of-code-that-could-have-prevented-thedao-hack-782499e00942/)

 ### 11. Elevator
 Explanation:
  * Much like the `@abstractclass` decorator in Python, interface merely declares the function but does not define it. This leaves malicious contract to manipulate the funciton implementation.

Solution:
   * To reach the top level, we need to toggle the return value of `isLastFloor` each time it is called. We can declare a variable and toggle its value between funciton calls: 
	
	
	toggler = toggler == false ? true : false;
	return toggler == false ?  true :  false;
	

Best Practice:
 * Using `view`	or `pure` modifiers to prevent state changing implementations. 
