pragma solidity ^0.6.0;

library BucketLib {
  struct Bucket {
    bytes32 key;
    bytes32 val;
    uint256 next;
  }
  function asBucket(uint256 ptr) internal pure returns (Bucket memory retval) {
    assembly {
      retval := ptr
    }
  }
  function toPtr(Bucket memory bucket) internal pure returns (uint256 retval) {
    assembly {
      retval := bucket
    }
  }
  function lookupValue(uint256 ptr, bytes32 key) internal pure returns (bytes32) {
    Bucket memory bucket = asBucket(ptr);
    while (true) {
      asBucket(ptr);
      if (bucket.key == key) return bucket.val;
      if (bucket.next == 0) return bytes32(uint256(0x0));
      ptr = bucket.next;
    }
  }
	function insertKeyValue(uint256 ptr, bytes32 key, bytes32 val) internal pure returns (Bucket memory) {
    while (true) {
      Bucket memory bucket = asBucket(ptr);
      if (bucket.key == key) {
        bucket.val = val;
        return bucket;
      }
      if (bucket.next == 0) {
        Bucket memory retval = initialize(key, val, 0);
        bucket.next = toPtr(retval);
        return retval;
      }
      ptr = bucket.next;
    }
  }
  function initialize(bytes32 key, bytes32 val, uint256 next) internal pure returns (Bucket memory) {
    return Bucket({
      key: key,
      val: val,
      next: next
    });
  }
}
