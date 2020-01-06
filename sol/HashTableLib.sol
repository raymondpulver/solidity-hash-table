 pragma solidity ^0.6.0;

import "./BTreeNodeLib.sol";
import "./BTreeExtensionLib.sol";
import "./BucketLib.sol";

library HashTableLib {
  using BTreeNodeLib for *;
  using BTreeExtensionLib for *;
  using BucketLib for *;
  uint256 constant NIBBLE_MASK = 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
  struct HashTable {
    BTreeNodeLib.BTreeNode ptr;
  }
  function initialize() internal pure returns (HashTable memory) {
    BTreeNodeLib.BTreeNode memory node = BTreeNodeLib.initialize();
    return HashTable({
      ptr: node
    });
  }
  function lookup(HashTable memory ht, bytes32 key) internal pure returns (bool exists, bytes32 val) {
    BTreeNodeLib.BTreeNode memory btn = ht.ptr;
    uint256 hash = uint256(keccak256(abi.encodePacked(key))) & ((uint256(0x1) << 0x20) - 1) & NIBBLE_MASK;
    for (uint256 i = 31; i > 27; i--) {
      if (btn.leafNode == 0) {
        if (btn.ptrs.length == 0) return (false, bytes32(uint256(0x0)));
        uint256 ptr = btn.get(uint256(uint8(bytes32(hash)[i])));
        if (ptr == 0) return (false, bytes32(uint256(0x0)));
        btn = ptr.asNode();
      } else {
        BTreeExtensionLib.BTreeExtension memory extension = btn.leafNode.asExtension();
        if (extension.hash == hash) return (true, extension.ptr.lookupValue(key));
        return (false, extension.ptr.lookupValue(key));
      }
    }
  }
  event Woop(bytes32 indexed data);
  function insert(HashTable memory ht, bytes32 key, bytes32 val) internal returns (BucketLib.Bucket memory) {
    BTreeNodeLib.BTreeNode memory btn = ht.ptr;
    uint256 hash = uint256(keccak256(abi.encodePacked(key))) & ((uint256(0x1) << uint256(0x20)) - 1) & NIBBLE_MASK;
    bytes memory placeholder;
    for (uint256 i = 31; i > 0; i--) {
      emit Woop(bytes32(hash));
      uint256 current = uint256(uint8(bytes32(hash)[i]));
      emit Woop(bytes32(current));
      if (btn.leafNode != 0) {
        BTreeExtensionLib.BTreeExtension memory extension = btn.leafNode.asExtension();
        if (extension.hash == hash) return extension.ptr.insertKeyValue(key, val);
        btn.leafNode = 0;
        btn.expand();
        BTreeNodeLib.BTreeNode memory node = BTreeNodeLib.initialize();
        BTreeExtensionLib.BTreeExtension memory lastExtended = BTreeExtensionLib.initialize(extension.hash, i - 1, extension.ptr);
        node.leafNode = lastExtended.toPtr();
        btn.set(extension.current, node.toPtr());
        if (extension.current != current) {
          BTreeNodeLib.BTreeNode memory newNode = BTreeNodeLib.initialize();
          btn.set(current, newNode.toPtr());
          btn = newNode;
        } else btn = node;
        placeholder = new bytes(0);
      } else {
        if (btn.ptrs.length == 0) {
          BTreeExtensionLib.BTreeExtension memory extension = BTreeExtensionLib.initialize(hash, i, 0);
          BucketLib.Bucket memory bucket = BucketLib.initialize(key, val, 0);
          extension.ptr = bucket.toPtr();
          btn.leafNode = extension.toPtr();
          return bucket;
        } else {
          uint256 ptr = btn.get(uint256(uint8(bytes32(hash)[i])));
          if (ptr == 0) {
            BucketLib.Bucket memory bucket = BucketLib.initialize(key, val, 0);
            BTreeExtensionLib.BTreeExtension memory extension = BTreeExtensionLib.initialize(hash, i, bucket.toPtr());
            BTreeNodeLib.BTreeNode memory node = BTreeNodeLib.initialize();
            node.leafNode = extension.toPtr();
            btn.set(uint256(uint8(bytes32(hash)[i])), node.toPtr());
          } else {
            btn = ptr.asNode();
          }
        }
      }
    }
    return BucketLib.Bucket({
      key: bytes32(uint256(0x0)),
      val: bytes32(uint256(0x0)),
      next: uint256(0x0)
    });
  }
}
