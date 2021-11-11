pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

/// @title ZombieHelper
/// @author Nicolas Maltais
/// @notice Helper functions 
contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;

  /// @notice Modifier to ensure a zombie is at or above a certain level
  /// @param _level uint
  /// @param _zombieId uint
  /// @return bool -> zombie level >= _level
  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }


  /// @dev Contract owner can withdraw fees
  function withdraw() external onlyOwner {
    address payable _owner = address(uint160(owner()));
    _owner.transfer(address(this).balance);
  }

  /// @notice Contract owner can adjust levelUp fee
  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }


  /// @notice Levels up Zombie +1 for a fee
  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level = zombies[_zombieId].level.add(1);
  }

  /// @notice Changes name of zombie, if owned by caller
  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
  }

  /// @notice Changes DNA of zombie, if owned by caller
  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].dna = _newDna;
  }


  /// @notice Get array of all zombies owned by owner in most gas-efficient way
  /// @param _owner Owner of zombies we which to retrieve
  /// @return uint[] of all indexes of zombies owned by _owner
  function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for(uint i = 0; i < zombies.length; i++) {
      if(zombieToOwner[i] == _owner){
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }




}
