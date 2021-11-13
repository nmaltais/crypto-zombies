pragma solidity >=0.5.0 <0.6.0;

import "./ZombieHelper.sol";

contract ZombieAttack is ZombieHelper {

  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  /// @notice Returns a random number from 0 to _modulus exclusive
  /// @param _modulus One above the highest possible return value 
  function randMod(uint _modulus) internal returns(uint) {
    randNonce = randNonce.add(1);
    return uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % _modulus;
  }

  /**
  * @notice One of your zombies attacks another zombie. 
  * If you win, your zombie levels up
  * , and a new zombie is added to your army through feedAndMultiply.
  * Triggers cooldown either way.
  */
  /// @param _zombieId Id of your zombie
  /// @param _targetId Id of enemy zombie
  function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    uint rand = randMod(100);
    if (rand <= attackVictoryProbability) {
      myZombie.winCount = myZombie.winCount.add(1);
      myZombie.level = myZombie.level.add(1);
      enemyZombie.lossCount = enemyZombie.lossCount.add(1);
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    }
    else {
      myZombie.lossCount = myZombie.lossCount.add(1);
      enemyZombie.winCount = enemyZombie.winCount.add(1);
      _triggerCooldown(myZombie);
    }
  }
}