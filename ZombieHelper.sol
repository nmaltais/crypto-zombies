pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

/**
* @title ZombieHelper
* @dev Helper functions 
*/
contract ZombieHelper is ZombieFeeding {

  /**
    @dev Modifier to ensure a zombie is at or above a certain level
    @param _level uint
    @param _zombieId uint
    @return bool -> zombie level >= _level
  */
  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  /**
    @dev Changes name of zombie, if owned by caller
  */
  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].name = _newName;
  }

  /**
    @dev Changes DNA of zombie, if owned by caller
  */
  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].dna = _newDna;
  }


  /**
    @dev Get array of all zombies owned by owner in most gas-efficient way
    @param _owner Owner of zombies we which to retrieve
    @return uint[] of all indexes of zombies owned by _owner
  */
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
