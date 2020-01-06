pragma solidity ^0.6.0;

library BTreeExtensionLib {
  struct BTreeExtension {
    uint256 current;
    uint256 prev;
    uint256 next;
    uint256 ptr;
  }
  function asExtension(uint256 ptr) internal pure returns (BTreeExtension memory retval) {
    assembly {
      retval := ptr
    }
  }
  function toPtr(BTreeExtension memory ext) internal pure returns (uint256 retval) {
    assembly {
      retval := ext
    }
  }
  function initialize(uint256 hash, uint256 byteIndex, uint256 ptr) internal pure returns (BTreeExtension memory) {
    uint256 nextMask = uint256(-1) << ((0x20 - byteIndex)*8);
    return BTreeExtension({
      current: uint256(uint8(bytes32(hash)[byteIndex])),
      prev: (~nextMask >> 8) & hash,
      next: nextMask & hash,
      ptr: ptr
    });
  }
  function toInputHash(BTreeExtension memory ext, uint256 byteIndex) internal pure returns (uint256) {
    return (ext.current << ((31 - byteIndex)*8)) | ext.prev | ext.next;
  }
}
