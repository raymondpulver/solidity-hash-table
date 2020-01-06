pragma solidity ^0.6.0;

library BTreeExtensionLib {
  struct BTreeExtension {
    uint256 current;
    uint256 hash;
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
    return BTreeExtension({
      current: uint256(uint8(bytes32(hash)[byteIndex])),
      hash: hash,
      ptr: ptr
    });
  }
}
