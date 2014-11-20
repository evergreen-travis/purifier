#!/usr/bin/env node
'use strict';

var cli = require('meow')({
  pkg: "../package.json",
  help: [
      'Usage',
      '  $ pb [options]',
      '\n  options:',
      '\t -p\t     specify the path.',
      '\t -i\t     files to ignore in the conversion.',
      '\t -e\t     specify extension to convert.',
      '\t -n\t     don\'t remove original files.',
      '\t --version   output the current version.',
      '\n  examples:',
      '\t pb -p $HOME/Projects/SecretUglyProject',
      '\t pb -e coffee',
      '\t pb -i test/ -e yml',
  ].join('\n')
});
