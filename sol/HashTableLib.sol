 pragma solidity ^0.6.0;

import "./BTreeNodeLib.sol";
import "./BTreeExtensionLib.sol";
import "./BucketLib.sol";

library HashTableLib {
  using BTreeNodeLib for *;
  using BTreeExtensionLib for *;
  using BucketLib for *;
  bytes32 constant NIBBLE_MASK = 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
  struct HashTable {
    uint32 ptr;
  }
  function create() internal pure returns (HashTable memory) {
    BTreeNodeLib.BTreeNode memory node = BTreeNodeLib.create();
    return HashTable({
      ptr: node.toPtr()
    });
  }
  function lookup(HashTable memory ht, bytes32 key) internal pure returns (bool exists, bytes32 val) {
    BTreeNodeLib.BTreeNode memory btn = ht.ptr.asNode();
    bytes32 hash = keccak256(abi.encodePacked(key)) & bytes32((uint256(0x1) << 0x20) - 1) & NIBBLE_MASK;
    for (uint256 i = 31; i > 27; i--) {
      if (btn.leafNode == 0) {
        if (btn.ptrs.length == 0) return (false, bytes32(uint256(0x0)));
        uint32 ptr = btn.ptrs[hash[i]];
        if (ptr == 0) return (false, bytes32(uint256(0x0)));
        btn = ptr.asNode();
      } else {
        BTreeExtensionLib.BTreeExtension memory extension = btn.leafNode.asExtension();
        if (extension.getInputHash(i) == hash) return (true, extension.ptr.lookupValue(key));
        return (false, extension.ptr.lookupValue(key));
      }
    }
  }
  function insert(HashTable memory ht, bytes32 key, bytes32 val) internal pure {
    BTreeNodeLib.BTreeNode memory btn = btn.ptr.asNode();
    bytes32 hash = keccak256(abi.encodePacked(key)) & bytes32((uint256(0x1) << uint256(0x20)) - 1) & NIBBLE_MASK;
    for (uint256 i = 31; i > 27; i--) {
      if (btn.leafNode != 0) {
        BTreeExtensionLib.BTreeExtension memory extension = btn.leafNode.asExtension();
        btn.leafNode = 0;
        btn.expand();
        BTreeNodeLib.BTreeNode memory node = BTreeNodeLib.create();
        btn.ptrs[extension.current] = node.toPtr();
        BTreeExtensionLib.BTreeExtension memory newExtension = BTreeExtensionLib.create(hash, i - 1, extension.ptr);
        node.leafNode = newExtension.toPtr();
        return (true, extension.ptr.insertKeyValue(key, val));
      } else {
        if (btn.ptrs.length == 0) {
          BucketLib.Bucket memory bucket = BucketLib.create(key, val, 0);
          BTreeExtensionLib.BTreeExtension memory extension = BTreeExtensionLib.create(hash, i, bucket.toPtr());
          btn.leafNode = extension.toPtr();
        } else {
          uint32 ptr = btn.ptrs[hash[i]];
          if (ptr == 0) {
            BucketLib.Bucket memory bucket = BucketLib.create(key, val, 0);
            BTreeExtensionLib.BTreeExtension memory extension = BTreeExtensionLib.create(hash, i, bucket.toPtr())
            BTreeNodeLib.BTreeNode memory node = BTreeNodeLib.create();
            node.leafNode = extension.toPtr();
            btn.ptrs[hash[i]] = node.toPtr();
          } else {
            btn = ptr.asNode();
          }
        }
      }
    }
  }
}
