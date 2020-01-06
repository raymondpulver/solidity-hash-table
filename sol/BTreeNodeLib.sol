 pragma solidity ^0.6.0;

library BTreeNodeLib {
  struct BTreeNode {
    uint256 leafNode;
    uint256[] ptrs;
  }
  function asNode(uint256 ptr) internal pure returns (BTreeNode memory retval) {
    assembly {
      retval := ptr
    }
  }
  function toPtr(BTreeNode memory btn) internal pure returns (uint256 retval) {
    assembly {
      retval := btn
    }
  }
  function expand(BTreeNode memory btn) internal pure {
    btn.ptrs = new uint256[](0x10);
  }
  function collapse(BTreeNode memory btn) internal pure {
    btn.ptrs = new uint256[](0x0);
  }
  function initialize() internal pure returns (BTreeNode memory) {
    return BTreeNode({
      leafNode: uint256(0x0),
      ptrs: new uint256[](0x0)
    });
  }
  function get(BTreeNode memory btn, uint256 i) internal pure returns (uint256 ptr) {
    ptr = btn.ptrs[i];
  }
  function set(BTreeNode memory btn, uint256 i, uint256 ptr) internal pure {
    btn.ptrs[i] = ptr;
  }
/*
  function get(BTreeNode memory btn, uint256 i) internal pure returns (uint256 ptr) {
    ptr = (btn.ptrs[(i >> 2)] >> ((0x7 - (i & 0x3))*0x20));
  }
  function set(BTreeNode memory btn, uint256 i, uint32 ptr) internal pure {
    uint256 index = i >> 2;
    uint256 entry = btn.ptrs[index];
    uint256 sector = i & 0x3;
    uint256 remaining = uint256(0x7) - sector;
    uint256 mask = 0xffffffff << (remaining * 0x20);
    uint256 poked = (entry & ~mask) | uint256(ptr) << (remaining * 0x20);
    btn.ptrs[index] = poked;
  }
*/
}
