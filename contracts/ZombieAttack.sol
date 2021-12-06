// SPDX-License-Identifier: MIT License
pragma solidity 0.8.10;

import "./ZombieHelper.sol";

contract ZombieAttack is ZombieHelper {
  uint256 randNonce = 0;
  uint256 attackVictoryProbability = 70;

  /// @notice Returns a random number from 0 to _modulus exclusive
  /// @param _modulus One above the highest possible return value
  function randMod(uint256 _modulus) internal returns (uint256) {
    randNonce = randNonce + 1;
    return
      uint256(
        keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))
      ) % _modulus;
  }

  /**
   * @notice One of your zombies attacks another zombie.
   * If you win, your zombie levels up
   * , and a new zombie is added to your army through feedAndMultiply.
   * Triggers cooldown either way.
   */
  /// @param _zombieId Id of your zombie
  /// @param _targetId Id of enemy zombie
  function attack(uint256 _zombieId, uint256 _targetId)
    external
    onlyOwnerOf(_zombieId)
  {
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    uint256 rand = randMod(100);
    if (rand <= attackVictoryProbability) {
      myZombie.winCount = myZombie.winCount + 1;
      myZombie.level = myZombie.level + 1;
      enemyZombie.lossCount = enemyZombie.lossCount + 1;
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    } else {
      myZombie.lossCount = myZombie.lossCount + 1;
      enemyZombie.winCount = enemyZombie.winCount + 1;
      _triggerCooldown(myZombie);
    }
  }
}
