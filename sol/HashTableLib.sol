 pragma solidity ^0.6.0;

library HashTableLib {
  struct BTreeNode {
    bytes4 leafNode;
    bytes4[] ptrs;
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
    bytes32 ptr;
  }
  function getBucketFromPtr(bytes32 ptr) internal pure returns (Bucket memory retval) {
    assembly {
      retval := ptr
    }
  }
  function lookupValueFromLeafNode(bytes32 leafNodePtr, bytes32 key) internal pure returns (bytes32) {
    LeafNode memory leafNode;
    assembly {
      leafNode := leafNodePtr
    }
    while (true) {
      assembly {
        leafNodePtr := leafNode
      }
      Bucket memory bucket = getBucketFromPtr(leafNode.bucket);
      if (bucket.key == key) return bucket.ptr;
      leafNode = getLeafNodeFromPtr(toBytes4(leafNode.next));
    }
  }
  function insertKeyValueFromLeafNode(bytes32 leafNodePtr, bytes32 key, bytes32 ptr) internal pure {
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
        break;
      } else {
        assembly {
          leafNodePtr := leafNode
        }
        if (leafNodePtr == 0) {
          leafNode = allocLeafNode();
        } else {
          leafNode = getLeafNodeFromPtr(toBytes4(leafNode.next));
          bucket = leafNode.bucket;
        }
      }
    }
  }
  function getOrAllocLeafNodeFromPtr(bytes4 ptr) internal pure returns (bytes4, LeafNode memory retval) {
    bytes4 resultPtr;
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
  function toPtr(LeafNode memory leafNode) internal pure returns (bytes4 ptr) {
    bytes32 word;
    assembly {
      word := leafNode
    }
    ptr = bytes4(uint32(uint256(word)));
  }
  function getLeafNodeFromPtr(bytes4 ptr) internal pure returns (LeafNode memory retval) {
    assembly {
      retval := ptr
    }
  }
  function toBytes4(bytes32 ptr) internal pure returns (bytes4 result) {
    result = bytes4(uint32(uint256(ptr)));
  }
  function fromBTreeNode(BTreeNode memory btn) internal pure returns (HashTable memory retval) {
    bytes32 ptr;
    assembly {
      ptr := btn
    }
    retval.ptr = ptr;
  }
  function getBTreeNode(HashTable memory ht) internal pure returns (BTreeNode memory retval) {
    bytes32 ptr = ht.ptr;
    assembly {
      retval := ptr
    }
  }
  function allocBTreeNode() internal pure returns (BTreeNode memory) {
    return BTreeNode({
      leafNode: bytes4(0x0),
      ptrs: new bytes4[](0x0)
    });
  }
  function getBTreeNodeFromPtr(bytes4 ptr) internal pure returns (BTreeNode memory retval) {
    assembly {
      retval := ptr
    }
  }
  function getOrAllocBTreeNodeFromPtr(bytes4 ptr) internal pure returns (bytes4, BTreeNode memory retval) {
    bytes4 resultPtr;
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
    if (btn.ptrs.length == 0) btn.ptrs = new bytes4[](0x100);
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
    retval.ptr = ptr;
  }
  function lookup(HashTable memory ht, bytes32 key) internal pure returns (bool exists, bytes32 val) {
    BTreeNode memory btn = getBTreeNode(ht);
    bytes32 hash = keccak256(abi.encodePacked(key)) & bytes32((uint256(0x1) << 0x20) - 1);
    for (uint256 i = 31; i > 27; i--) {
      if ((~bytes32((uint256(0x1) << (i + 1)*8) - 1) & hash) == 0) {
        if (btn.leafNode != 0) return (true, lookupValueFromLeafNode(bytes32(uint256(uint32(btn.leafNode))), key));
        return (false, bytes32(uint256(0x0)));
      }
      uint256 b = uint256(uint8(hash[i]));
      if (btn.ptrs.length == 0) return (false, bytes32(uint256(0x0)));
      bytes4 ptr = bytes4(uint32(btn.ptrs[b]));
      if (ptr == 0) return (false, bytes32(uint256(0x0)));
      btn = getBTreeNodeFromPtr(ptr);
    }
  }
  function insert(HashTable memory ht, bytes32 key, bytes32 val) internal pure {
    BTreeNode memory btn = getBTreeNode(ht);
    bytes32 hash = keccak256(abi.encodePacked(key)) & bytes32((uint256(0x1) << uint256(0x20)) - 1);
    for (uint256 i = 31; i > 27; i--) {
      if ((~bytes32((0x1 << (i + 1)*8) - 1) & hash) == 0) {
        
        btn.leafNode = toPtr(allocLeafNode());
        insertKeyValueFromLeafNode(bytes32(uint256(uint32(btn.leafNode))), key, val);
      }
      possiblyExpandBTreePtrs(btn);
      uint256 b = uint256(uint8(hash[i]));
      bytes4 ptr = btn.ptrs[b];
      (ptr, btn) = getOrAllocBTreeNodeFromPtr(ptr);
    }
  }
}
