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
    uint256 ptr;
  }
  function initialize() internal pure returns (HashTable memory) {
    BTreeNodeLib.BTreeNode memory node = BTreeNodeLib.initialize();
    return HashTable({
      ptr: node.toPtr()
    });
  }
  function lookup(HashTable memory ht, bytes32 key) internal pure returns (bool exists, bytes32 val) {
    BTreeNodeLib.BTreeNode memory btn = ht.ptr.asNode();
    uint256 hash = uint256(keccak256(abi.encodePacked(key))) & ((uint256(0x1) << 0x20) - 1) & NIBBLE_MASK;
    for (uint256 i = 31; i > 27; i--) {
      if (btn.leafNode == 0) {
        if (btn.ptrs.length == 0) return (false, bytes32(uint256(0x0)));
        uint256 ptr = btn.get(uint256(uint8(bytes32(hash)[i])));
        if (ptr == 0) return (false, bytes32(uint256(0x0)));
        btn = ptr.asNode();
      } else {
        BTreeExtensionLib.BTreeExtension memory extension = btn.leafNode.asExtension();
        if (extension.toInputHash(i) == hash) return (true, extension.ptr.lookupValue(key));
        return (false, extension.ptr.lookupValue(key));
      }
    }
  }
  function insert(HashTable memory ht, bytes32 key, bytes32 val) internal pure {
    BTreeNodeLib.BTreeNode memory btn = ht.ptr.asNode();
    uint256 hash = uint256(keccak256(abi.encodePacked(key))) & ((uint256(0x1) << uint256(0x20)) - 1) & NIBBLE_MASK;
    for (uint256 i = 31; i > 27; i--) {
      if (btn.leafNode != 0) {
        BTreeExtensionLib.BTreeExtension memory extension = btn.leafNode.asExtension();
        btn.leafNode = 0;
        btn.expand();
        BTreeNodeLib.BTreeNode memory node = BTreeNodeLib.initialize();
        btn.set(extension.current, node.toPtr());
        BTreeExtensionLib.BTreeExtension memory newExtension = BTreeExtensionLib.initialize(hash, i - 1, extension.ptr);
        node.leafNode = newExtension.toPtr();
        extension.ptr.insertKeyValue(key, val);
        return;
      } else {
        if (btn.ptrs.length == 0) {
          BucketLib.Bucket memory bucket = BucketLib.initialize(key, val, 0);
          BTreeExtensionLib.BTreeExtension memory extension = BTreeExtensionLib.initialize(hash, i, bucket.toPtr());
          btn.leafNode = extension.toPtr();
          extension.ptr.insertKeyValue(key, val);
          return;
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
  }
}
