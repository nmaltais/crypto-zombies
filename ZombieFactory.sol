pragma solidity >=0.5.0 <0.6.0;

/**
  Creaes Zombies
  Zombies have a 16-digit DNA number which determines their appearance. 
    1st pair of digits determines hat type
    2nd pair - eye type
    3rd pair - shirt type
    4th pair - skin color
    5th - eye color 
    6th - clothes color
 */
contract ZombieFactory {

  // Event that will be emited when a new zombie is created, which can be captured by our frontend app
  event NewZombie(uint zombieId, string name, uint dna);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;

  struct Zombie {
    string name;
    uint dna;
  }

  // Public dynamic array of Zombie structs
  Zombie[] public zombies;

  // Creates zombies, _name is passed by value
  function _createZombie(string memory _name, uint _dna) private {
    uint id = zombies.push(Zombie(_name, _dna)) - 1;
    // Emit event
    emit NewZombie(id, _name, _dna);
  } 

  // Creates a 16-bit pseudo-random dna based on an input string
  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  // Public function which creates a random Zombie based on a given name
  function createRandomZombie(string memory _name) public {
    uint randDna = _generateRandomDna(_name);
    _createZombie(_name, randDna);
  }

}