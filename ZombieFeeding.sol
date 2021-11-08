pragma solidity >=0.5.0 <0.6.0;
import "./ZombieFactory.sol";

/**
* @dev Use function from public CryptoKitty contract -- Zombies love eating kitties
*/
contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

/**
* @title ZombieFeeding
* @dev Ability for Zombies to eat other Zombies, and Kitties
*/
contract ZombieFeeding is ZombieFactory {

  modifier ownerOf(uint _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    _;
  }

  // Access to kitty contract
  KittyInterface kittyContract;
  function setKittyContractAddress(address _address) external {
    kittyContract = KittyInterface(_address);
  }

  /**
  * @dev Sets cooldown for a Zombie, called after a zombie feeds
  * @param _zombie Zombie from storage
  */
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

  /**
  * @dev Checks whether Zombie can eat again
  * @param _zombie Zombie from storage
  * @return bool - If ready time <= now
  */
  function _isReady(Zombie storage _zombie) internal view returns (bool) {
    return (_zombie.readyTime <= now);
  }


  /**
  * @dev When a zombie feeds on some other lifeform, its DNA will combine with the other lifeform's DNA to create a new zombie.
  * @param _zombieId ID of the Zombie
  * @param _targetDna DNA of the target lifeform
  * @param _species The type of lifeform of the target being consumed by the Zombie
  */
  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal ownerOf(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];
    require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if(keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))){
        newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);
  }

  /**
  * @dev Feed on a Kitty, retrieve dna based on _kittyID
  * @param _zombieId ID of the Zombie
  * @param _kittyId ID of the Kitty
  */
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
      uint kittyDna;
      (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
      feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}