// SPDX-License-Identifier: MIT License
pragma solidity 0.8.10;
import "./Ownable.sol";

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
contract ZombieFactory is Ownable {
  /// @notice Event that will be emited when a new zombie is created, which can be captured by our frontend app
  event NewZombie(uint256 zombieId, string name, uint256 dna);

  uint256 dnaDigits = 16;
  uint256 dnaModulus = 10**dnaDigits;
  uint256 cooldownTime = 1 days;

  struct Zombie {
    string name;
    uint256 dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }

  // Public dynamic array of Zombie structs
  Zombie[] public zombies;

  // Keep track of which zombie belongs to which user, and how many zombies a user has
  mapping(uint256 => address) public zombieToOwner;
  mapping(address => uint256) ownerZombieCount;

  /// @notice Creates zombies, marks their owner. Emits the NewZombie event.
  /// @param _name Name of the Zombie
  /// @param _dna DNA of the Zombie
  function _createZombie(string memory _name, uint256 _dna) internal {
    zombies.push(
      Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0)
    );
    uint256 id = zombies.length - 1;
    // Update mappings
    zombieToOwner[id] = msg.sender;
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender] + 1;
    // Emit event
    emit NewZombie(id, _name, _dna);
  }

  /// @notice Creates a 16-bit pseudo-random dna based on an input string
  /// @param _str User-inputed string
  /// @return 16-bit pseudo-random uint, which will be used as dna
  function _generateRandomDna(string memory _str)
    private
    view
    returns (uint256)
  {
    uint256 rand = uint256(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  /// @notice Creates a random Zombie based on a given input _name.
  /// @param _name Name of the Zombie. Used to create the DNA.
  function createRandomZombie(string memory _name) public {
    // Only allow players to create one zombie
    require(ownerZombieCount[msg.sender] == 0);
    uint256 randDna = _generateRandomDna(_name);
    _createZombie(_name, randDna);
  }
}
