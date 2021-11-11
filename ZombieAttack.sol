pragma solidity >=0.5.0 <0.6.0;

import "./zombiehelper.sol";

contract ZombieAttack is ZombieHelper {

  uint randNonce = 0;
  uint attackVictoryProbability = 70;


  /**
  * @dev Returns a random number from 0 to _modulus exclusive
  * @param _modulus One above the highest possible return value 
  */
  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % _modulus;
  }

  /**
  * @dev One of your zombies attacks another zombie. 
  * If you win, your zombie levels up
  * , and a new zombie is added to your army through feedAndMultiply.
  * Triggers cooldown either way.
  * @param _zombieId Id of your zombie
  * @param _targetId Id of enemy zombie
  */
  function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    uint rand = randMod(100);
    if (rand <= attackVictoryProbability) {
      myZombie.winCount++;
      myZombie.level++;
      enemyZombie.lossCount++;
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    }
    else {
      myZombie.lossCount++;
      enemyZombie.winCount++;
      _triggerCooldown(myZombie);
    }
  }
}