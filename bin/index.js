#!/usr/bin/env node
'use strict';
var Purifier = require('..');
var chalk = require('chalk');
var cli = require('meow')({
  pkg: '../package.json',
  help: [
      'Usage',
      '  $ purifier [rootPath][options]',
      '\n  options:',
      '\t -i\t     files to ignore in the conversion.',
      '\t -e\t     specify extension to convert.',
      '\t -n\t     don\'t remove original files.',
      '\t --version   output the current version.',
      '\n  examples:',
      '\t purifier $HOME/Projects/SecretUglyProject',
      '\t purifier $HOME/Projects/SecretUglyProject -e js -e json',
      '\t purifier $HOME/Projects/SecretUglyProject -e js -e json -i bin',
  ].join('\n')
});

var rootPath = cli.input[0] || process.cwd();
var opts = {
  remove: cli.flags.n === undefined ? true : !cli.flags.n,
  save: true,
  verbose: false,
  ignore: cli.flags.i || [],
  extensions: (function() {
    if (typeof cli.flags.e === 'string') {
      return new Array(cli.flags.e);
    } else if (typeof cli.flags.e === 'object'){
      return cli.flags.e;
    } else {
      return [];
    }
  })()
};

Purifier.transformFolder(rootPath, opts, function(counter){
  if (counter) {
    console.log('\n', chalk.bold(counter + ' files'), 'has been purified.');
  } else {
    console.log('\n', chalk.underline('Nothing'),'to purify.');
  }
});
