'use strict';

const child_process = require('child_process');
const { spawnSync } = child_process;
const path = require('path');
const fs = require('fs');
const addHexPrefix = (s) => s.substr(0, 2) === '0x' ? s : '0x' + s;
const mkdirp = require('mkdirp');

process.chdir(__dirname);
spawnSync('npx', ['solcjs', path.join('sol', 'BTreeExtensionLib.sol'), path.join('sol', 'BTreeNodeLib.sol'), path.join('sol', 'BucketLib.sol'), path.join('test', 'HashTableTest.sol'), path.join('sol', 'HashTableLib.sol'), '-o', path.join('build', 'artifacts'), '--bin'], { stdio: 'inherit' });
const artifactsDir = path.join(__dirname, 'build', 'artifacts');
mkdirp.sync(artifactsDir);
fs.writeFileSync(path.join(__dirname, 'build', 'build.json'), JSON.stringify({
	bytecode: addHexPrefix(fs.readFileSync(path.join(artifactsDir, 'sol_HashTableLib_sol_HashTableLib.bin'), 'utf8')),
  src: fs.readFileSync(path.join(__dirname, 'sol', 'HashTableLib.sol'), 'utf8')
}, null, 1))
