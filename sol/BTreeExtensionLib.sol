pragma solidity ^0.6.0;

library BTreeExtensionLib {
  struct BTreeExtension {
    uint8 single;
    uint32 prev;
    uint32 next;
    uint32 ptr;
  }
  function asExtension(uint32 ptr) internal pure returns (BTreeExtension memory retval) {
    assembly {
      retval := ptr
    }
  }
  function create(bytes32 hash, uint256 byteIndex, uint32 ptr) internal pure returns (BTreeExtension memory) {
    uint256 nextMask = bytes32(int256(-1)) << ((32 - byteIndex)*8);
    return BTreeExtension({
      single: hash[byteIndex],
      prev: (~nextMask) >> 8,
      next: nextMask,
      ptr: ptr
    });
  }
  function toInputHash(BTreeExtension memory ext, uint256 byteIndex) internal pure returns (bytes32) {
    return uint256(ext.current) << ((31 - byteIndex)*8) | ext.prev | ext.next;
  }
}

