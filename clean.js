const rimraf = require('rimraf');
const path = require('path');

(async () => {
	await new Promise((resolve, reject) => rimraf(path.join(__dirname, 'build'), (err) => err ? reject(err) : resolve()));
})().catch((err) => console.error(err.stack));
