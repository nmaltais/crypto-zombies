pragma solidity >=0.5.0 <0.6.0;

import "./ZombieFactory.sol";

// Use function from public CryptoKitty contract -- Zombies love eating kitties
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
  Ability for Zombies to eat other Zombies, and Kitties
 */
contract ZombieFactory is ZombieFactory {

  // Access to kitty contract
  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  KittyInterface kittyContract = KittyInterface(ckAddress);

  // When a zombie feeds on some other lifeform, its DNA will combine with the other lifeform's DNA to create a new zombie.
  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if(keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))){
        newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
  }
  // Get kitty DNA based on kitty ID and feed on it
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
      uint kittyDna;
      (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
      feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}