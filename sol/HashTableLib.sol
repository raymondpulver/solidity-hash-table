 pragma solidity ^0.6.0;

library HashTableLib {
  struct BTreeNode {
    uint32 leafNode;
    uint32[] ptrs;
  }
  struct Bucket {
    bytes32 key;
    bytes32 ptr;
  }
  struct LeafNode {
    bytes32 bucket;
    bytes32 next;
  }
  struct HashTable {
    uint32 ptr;
  }
  function toUint32(bytes32 ptr) internal pure returns (uint32) {
    return uint32(uint256(ptr));
  }
  function getBucketFromPtr(bytes32 ptr) internal pure returns (Bucket memory retval) {
    assembly {
      retval := ptr
    }
  }
  function lookupValueFromLeafNode(uint32 leafNodePtr, bytes32 key) internal pure returns (bytes32) {
    LeafNode memory leafNode;
    assembly {
      leafNode := leafNodePtr
    }
    while (true) {
      assembly {
        leafNodePtr := leafNode
      }
      if (leafNode.bucket == 0) return bytes32(0x0);
      Bucket memory bucket = getBucketFromPtr(leafNode.bucket);
      if (bucket.key == key) return bucket.ptr;
      if (leafNode.next == 0) return bytes32(uint256(0x0));
      leafNode = getLeafNodeFromPtr(toUint32(leafNode.next));
    }
  }
  function insertKeyValueFromLeafNode(uint32 leafNodePtr, bytes32 key, bytes32 ptr) internal pure {
    LeafNode memory leafNode;
    assembly {
      leafNode := leafNodePtr
    }
    bytes32 bucket = leafNode.bucket;
    Bucket memory newBucket;
    while (true) {
      if (bucket == 0) {
        newBucket = Bucket({
          key: key,
          ptr: ptr
        });
        assembly {
          bucket := newBucket
        }
        leafNode.bucket = bucket;
        break;
      } else {
        assembly {
          leafNodePtr := leafNode
        }
        if (leafNodePtr == 0) {
          leafNode = allocLeafNode();
        } else {
          bytes32 currentBucket = leafNode.bucket;
          assembly {
            newBucket := currentBucket
          }
          if (newBucket.key == key) { 
            newBucket.ptr = ptr;
            return;
          }
          leafNode = getLeafNodeFromPtr(toUint32(leafNode.next));
          bucket = leafNode.bucket;
        }
      }
    }
  }
  function getOrAllocLeafNodeFromPtr(uint32 ptr) internal pure returns (uint32, LeafNode memory retval) {
    uint32 resultPtr;
    if (ptr == 0) {
      retval = allocLeafNode();
      assembly {
        resultPtr := retval
      }
      return (resultPtr, retval);
    }
    return (ptr, getLeafNodeFromPtr(ptr));
  }
  function allocLeafNode() internal pure returns (LeafNode memory) {
    return LeafNode({
      bucket: bytes32(0x0),
      next: bytes32(0x0)
    });
  }
  function toPtr(LeafNode memory leafNode) internal pure returns (uint32 ptr) {
    assembly {
      ptr := leafNode
    }
  }
  function getLeafNodeFromPtr(uint32 ptr) internal pure returns (LeafNode memory retval) {
    assembly {
      retval := ptr
    }
  }
  function fromBTreeNode(BTreeNode memory btn) internal pure returns (HashTable memory retval) {
    uint32 ptr;
    assembly {
      ptr := btn
    }
    retval.ptr = ptr;
  }
  function getBTreeNode(HashTable memory ht) internal pure returns (BTreeNode memory retval) {
    uint32 ptr = ht.ptr;
    assembly {
      retval := ptr
    }
  }
  function allocBTreeNode() internal pure returns (BTreeNode memory) {
    return BTreeNode({
      leafNode: uint32(0x0),
      ptrs: new uint32[](0x0)
    });
  }
  function getBTreeNodeFromPtr(uint32 ptr) internal pure returns (BTreeNode memory retval) {
    assembly {
      retval := ptr
    }
  }
  function getOrAllocBTreeNodeFromPtr(uint32 ptr) internal pure returns (uint32, BTreeNode memory retval) {
    uint32 resultPtr;
    if (ptr == 0) {
      retval = allocBTreeNode();
      assembly {
        resultPtr := retval
      }
      return (resultPtr, retval);
    }
    return (ptr, getBTreeNodeFromPtr(ptr));
  }
  function possiblyExpandBTreePtrs(BTreeNode memory btn) internal pure {
    if (btn.ptrs.length == 0) btn.ptrs = new uint32[](0x10);
  }
  function createHashTable() internal pure returns (HashTable memory) {
    BTreeNode memory encapsulated = allocBTreeNode();
    HashTable memory retval = HashTable({
      ptr: 0
    }); 
    bytes32 ptr;
    assembly {
      ptr := encapsulated
    }
    retval.ptr = uint32(uint256(ptr));
  }
  bytes32 constant NIBBLE_MASK = 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
  function lookup(HashTable memory ht, bytes32 key) internal pure returns (bool exists, bytes32 val) {
    BTreeNode memory btn = getBTreeNode(ht);
    bytes32 hash = keccak256(abi.encodePacked(key)) & bytes32((uint256(0x1) << 0x20) - 1) & NIBBLE_MASK;
    for (uint256 i = 31; i > 27; i--) {
      if ((~bytes32((uint256(0x1) << (i + 1)*8) - 1) & hash) == 0) {
        if (btn.leafNode != 0) return (true, lookupValueFromLeafNode(btn.leafNode, key));
        return (false, bytes32(uint256(0x0)));
      }
      uint256 b = uint256(uint8(hash[i]));
      if (btn.ptrs.length == 0) return (false, bytes32(uint256(0x0)));
      uint32 ptr = uint32(btn.ptrs[b]);
      if (ptr == 0) return (false, bytes32(uint256(0x0)));
      btn = getBTreeNodeFromPtr(ptr);
    }
  }
  function insert(HashTable memory ht, bytes32 key, bytes32 val) internal pure {
    BTreeNode memory btn = getBTreeNode(ht);
    bytes32 hash = keccak256(abi.encodePacked(key)) & bytes32((uint256(0x1) << uint256(0x20)) - 1) & NIBBLE_MASK;
    for (uint256 i = 31; i > 27; i--) {
      if ((~bytes32((0x1 << (i + 1)*8) - 1) & hash) == 0) {
        
        btn.leafNode = toPtr(allocLeafNode());
        insertKeyValueFromLeafNode(btn.leafNode, key, val);
        return;
      }
      possiblyExpandBTreePtrs(btn);
      uint256 b = uint256(uint8(hash[i]));
      uint32 ptr = btn.ptrs[b];
      (ptr, btn) = getOrAllocBTreeNodeFromPtr(ptr);
    }
  }
}
