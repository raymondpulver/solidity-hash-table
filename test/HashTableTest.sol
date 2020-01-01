pragma solidity	^0.6.0;

import "../sol/HashTableLib.sol";

contract HashTableTest {
  using HashTableLib for *;
  event Data(bytes32 indexed arg);
  constructor() public {
    HashTableLib.HashTable memory ht = HashTableLib.createHashTable();
    ht.insert(bytes32(uint256(0x2)), bytes32(uint256(0x3)));
    (bool found, bytes32 val) = ht.lookup(bytes32(uint256(0x2)));
    require(found);
    if (found || !found) emit Data(val);
  }
} 
