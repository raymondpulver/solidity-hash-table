 pragma solidity ^0.6.0;

library BTreeNodeLib {
  struct BTreeNode {
    uint32 leafNode;
    uint32[] ptrs;
  }
  function asNode(uint32 ptr) internal pure returns (BTreeNode memory retval) {
    assembly {
      retval := ptr
    }
  }
  function expand(BTreeNode memory btn) internal pure {
    btn.ptrs = new uint32[](0x10);
  }
  function collapse(BTreeNode memory btn) internal pure {
    btn.ptrs = new uint32[](0x0);
  }
  function create() internal pure returns (BTreeNode memory) {
    return BTreeNode({
      leafNode: uint32(0x0),
      ptrs: new uint32[](0x0)
    });
  }
}