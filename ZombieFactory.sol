pragma solidity >=0.5.0 <0.6.0;
import "./Ownable.sol";
import "./safemath.sol";

/// @title ZombieFactory
/** @notice Creates Zombies
*  Zombies have a 16-digit DNA number which determines their appearance. 
*   1st pair of digits determines hat type
*   2nd pair - eye type
*   3rd pair - shirt type
*   4th pair - skin color
*   5th - eye color 
*   6th - clothes color
*/
contract ZombieFactory is Ownable{

  using SafeMath for uint256;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;

  /// @notice Event that will be emited when a new zombie is created, which can be captured by our frontend app
  event NewZombie(uint zombieId, string name, uint dna);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 1 days;

  struct Zombie {
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }

  // Public dynamic array of Zombie structs
  Zombie[] public zombies;

  // Keep track of which zombie belongs to which user, and how many zombies a user has
  mapping (uint => address) public zombieToOwner;
  mapping (address => uint) ownerZombieCount;

  /// @notice Creates zombies, marks their owner. Emits the NewZombie event.
  /// @param _name Name of the Zombie
  /// @param _dna DNA of the Zombie
  function _createZombie(string memory _name, uint _dna) internal {
    uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
    // Update mappings
    zombieToOwner[id] = msg.sender;
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
    // Emit event
    emit NewZombie(id, _name, _dna);
  } 

  /// @notice Creates a 16-bit pseudo-random dna based on an input string
  /// @param _str User-inputed string
  /// @return 16-bit pseudo-random uint, which will be used as dna
  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  /// @notice Creates a random Zombie based on a given input _name.
  /// @param _name Name of the Zombie. Used to create the DNA.
  function createRandomZombie(string memory _name) public {
    // Only allow players to create one zombie
    require(ownerZombieCount[msg.sender] == 0);
    uint randDna = _generateRandomDna(_name);
    _createZombie(_name, randDna);
  }

}