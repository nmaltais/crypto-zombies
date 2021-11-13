pragma solidity >=0.5.0 <0.6.0;

import "./ZombieAttack.sol";
import "./erc721.sol";
import "./safemath.sol";

/// @title A contract that manages transfering zombie ownership
/// @author Nicolas Maltais
/// @dev Compliant with OpenZeppelin's implementation of the ERC721 spec draft
contract ZombieOwnership is ZombieAttack, ERC721 {
  // Provides functions to prevent overflows and underflows
  using SafeMath for uint256;

  // Mapping tokenId to address who is approved to transfer it.
  mapping (uint => address) zombieApprovals;

  /// @notice Returns how many zombies an address owns.
  function balanceOf(address _owner) external view returns (uint256) {
    return ownerZombieCount[_owner];
  }

  /// @notice returns the address of the owner of a zombie.
  function ownerOf(uint256 _tokenId) external view returns (address) {
    return zombieToOwner[_tokenId];
  }

  /// @notice utility function to execute the transfer of a zombie.
  /// @dev Emits ERC721 Transfer event.
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId); //Emit event from ERC721
  }

  /// @notice external, payable function for owner or approved address to trigger a transfer.
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
    // Make sure caller is either owner of the zombie, or has been approved to transfer.
    require(zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
    _transfer(_from, _to, _tokenId);
  }

  /// @notice owner of a zombie can set an approved address to have them be able to call transferFrom sucessfully.
  /// @dev Emits ERC721 Approval event
  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
    zombieApprovals[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);//Emit event from ERC721
  }
}