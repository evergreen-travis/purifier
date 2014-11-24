#!/usr/bin/env node
'use strict';
var Purifier = require('..');
var cli = require('meow')({
  pkg: "../package.json",
  help: [
      'Usage',
      '  $ purifier [options]',
      '\n  options:',
      '\t -p\t     specify the path.',
      '\t -i\t     files to ignore in the conversion.',
      '\t -e\t     specify extension to convert.',
      '\t -n\t     don\'t remove original files.',
      '\t --version   output the current version.',
      '\n  examples:',
      '\t purifier -p $HOME/Projects/SecretUglyProject',
      '\t purifier -e coffee',
      '\t purifier -i test/ -e yml',
  ].join('\n')
});

var dir = cli.flags.p || process.cwd();
var opts = {
  remove: !cli.flags.n|| true,
  ignore: cli.flags.i || null,
  ext: cli.flags.e
};

console.log(cli.flags);
console.log(dir);
console.log(opts);

// console.log();
// console.log(Purifier.convertFile);
