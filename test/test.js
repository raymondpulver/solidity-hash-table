'use strict';

const fs = require('fs');
const path = require('path');
const { addHexPrefix } = require('ethereumjs-util');
const src = addHexPrefix(fs.readFileSync(path.join(__dirname, '..', 'build', 'artifacts', 'test_HashTableTest_sol_HashTableTest.bin'), 'utf8'));
const rpcCall = require('kool-makerpccall');
const call = (method, params = []) => rpcCall('http://localhost:8545', method, params);

describe('solidity hash table', () => {
	it('works', async () => {
	  const [ from ] = await call('eth_accounts');
		const txHash = await call('eth_sendTransaction', [{
			from,
			gasPrice: '0x1',
			gas: '0x' + (3e6).toString(16),
			data: src
		}]);
		const receipt = await call('eth_getTransactionReceipt', [ txHash ]);
		console.log(receipt.logs[0].topics);
	});
});
