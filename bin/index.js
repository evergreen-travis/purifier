#!/usr/bin/env node
'use strict';
require('shelljs/global');

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

console.log(cli.showHelp());
// console.log(find('.').filter(function(file) { return file.match(/\.js$/); }));

