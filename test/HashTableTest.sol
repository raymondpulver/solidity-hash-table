pragma solidity	^0.6.0;

import "../sol/HashTableLib.sol";

contract HashTableTest {
  using HashTableLib for *;
  event GasUsed(uint256 indexed arg);
  event Data(bytes32 indexed data);
  constructor() public {
    HashTableLib.HashTable memory ht = HashTableLib.createHashTable();
    uint256 start = gasleft();
    ht.insert(bytes32(uint256(0x2)), bytes32(uint256(0x3)));
    emit GasUsed(start - gasleft());
    start = gasleft();
    (bool found, bytes32 val) = ht.lookup(bytes32(uint256(0x2)));
    emit GasUsed(start - gasleft());
    start = gasleft();
    ht.insert(bytes32(uint256(0x4)), bytes32(uint256(0x5)));
    emit GasUsed(start - gasleft());
    start = gasleft();
    ht.insert(bytes32(uint256(0x5)), bytes32(uint256(0x5)));
    emit GasUsed(start - gasleft());
    require(found);
    if (found || !found) emit Data(val);
  }
} 
