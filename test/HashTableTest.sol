pragma solidity	^0.6.0;

import "../sol/HashTableLib.sol";

contract HashTableTest {
  using HashTableLib for *;
  event GasUsed(uint256 indexed arg);
  event Data(bytes32 indexed data);
  function callLookup(HashTableLib.HashTable memory ht, bytes32 key) internal pure returns (uint256) {
    (bool success, bytes32 val) = ht.lookup(key);
    if (success || !success) return uint256(val);
  }
  constructor() public {
    HashTableLib.HashTable memory ht = HashTableLib.createHashTable();
    uint256 start = gasleft();
    ht.insert(bytes32(uint256(0x2)), bytes32(uint256(0x3)));
    emit GasUsed(start - gasleft());
    start = gasleft();
    (bool found, bytes32 val) = ht.lookup(bytes32(uint256(0x2)));
    emit GasUsed(uint256(val));
    emit GasUsed(start - gasleft());
    start = gasleft();
    ht.insert(bytes32(uint256(0x4)), bytes32(uint256(0x5)));
    emit GasUsed(start - gasleft());
    start = gasleft();
    ht.insert(bytes32(uint256(0x5)), bytes32(uint256(0x5)));
    emit GasUsed(start - gasleft());
    emit GasUsed(callLookup(ht, bytes32(uint256(0x2))));
		emit GasUsed(callLookup(ht, bytes32(uint256(0x4))));
    emit GasUsed(callLookup(ht, bytes32(uint256(0x5))));
    require(found);
    if (found || !found) emit Data(val);
  }
} 
