// SPDX-License-Identifier: MIT License
pragma solidity 0.8.10;

import "./ZombieFeeding.sol";

/// @title ZombieHelper
/// @author Nicolas Maltais
/// @notice Helper functions
contract ZombieHelper is ZombieFeeding {
  uint256 levelUpFee = 0.001 ether;

  /// @notice Modifier to ensure a zombie is at or above a certain level
  /// @param _level uint
  /// @param _zombieId uint
  modifier aboveLevel(uint256 _level, uint256 _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  /// @dev Contract owner can withdraw fees
  function withdraw() external onlyOwner {
    address payable _owner = payable(address(uint160(owner())));
    _owner.transfer(address(this).balance);
  }

  /// @notice Contract owner can adjust levelUp fee
  function setLevelUpFee(uint256 _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  /// @notice Levels up Zombie +1 for a fee
  function levelUp(uint256 _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level = zombies[_zombieId].level + 1;
  }

  /// @notice Changes name of zombie, if owned by caller
  function changeName(uint256 _zombieId, string calldata _newName)
    external
    aboveLevel(2, _zombieId)
    onlyOwnerOf(_zombieId)
  {
    zombies[_zombieId].name = _newName;
  }

  /// @notice Changes DNA of zombie, if owned by caller
  function changeDna(uint256 _zombieId, uint256 _newDna)
    external
    aboveLevel(20, _zombieId)
    onlyOwnerOf(_zombieId)
  {
    zombies[_zombieId].dna = _newDna;
  }

  /// @notice Get array of all zombies owned by owner in most gas-efficient way
  /// @param _owner Owner of zombies we which to retrieve
  /// @return uint[] of all indexes of zombies owned by _owner
  function getZombiesByOwner(address _owner)
    external
    view
    returns (uint256[] memory)
  {
    uint256[] memory result = new uint256[](ownerZombieCount[_owner]);
    uint256 counter = 0;
    for (uint256 i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
}
