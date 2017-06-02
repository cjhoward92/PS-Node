const entry = require('./output/Main/index');

console.log(process.env.NODE_ENV);

// This calls to the built code
entry.main();