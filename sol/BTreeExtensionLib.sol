pragma solidity ^0.6.0;

library BTreeExtensionLib {
  struct BTreeExtension {
    uint8 current;
    uint32 prev;
    uint32 next;
    uint32 ptr;
  }
  function asExtension(uint32 ptr) internal pure returns (BTreeExtension memory retval) {
    assembly {
      retval := ptr
    }
  }
  function toPtr(BTreeExtension memory ext) internal pure returns (uint32 retval) {
    assembly {
      retval := ext
    }
  }
  function initialize(bytes32 hash, uint256 byteIndex, uint32 ptr) internal pure returns (BTreeExtension memory) {
    uint256 nextMask = uint256(bytes32(int256(-1))) << ((32 - byteIndex)*8);
    return BTreeExtension({
      current: uint8(hash[byteIndex]),
      prev: uint32(uint256(bytes32(((~nextMask) >> 8)) & hash)),
      next: uint32(uint256(bytes32(nextMask) & hash)),
      ptr: ptr
    });
  }
  function toInputHash(BTreeExtension memory ext, uint256 byteIndex) internal pure returns (bytes32) {
    return bytes32(uint256(ext.current) << ((31 - byteIndex)*8) | ext.prev | ext.next);
  }
}

