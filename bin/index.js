#!/usr/bin/env node
'use strict';
var Purifier = require('..');
var cli = require('meow')({
  pkg: "../package.json",
  help: [
      'Usage',
      '  $ purifier [path][options]',
      '\n  options:',
      '\t -i\t     files to ignore in the conversion.',
      '\t -e\t     specify extension to convert.',
      '\t -n\t     don\'t remove original files.',
      '\t --version   output the current version.',
      '\n  examples:',
      '\t purifier $HOME/Projects/SecretUglyProject',
      '\t purifier -e coffee',
      '\t purifier -i bin -i client -e yml',
  ].join('\n')
});

var dir = cli.input[0] || process.cwd();
var opts = {
  remove: !cli.flags.n|| true,
  save: true,
  ignore: cli.flags.i,
  ext: determinateExtension()
};

function determinateExtension(){
  if (typeof cli.flags.e === 'string')
    return new Array(cli.flags.e);
  else
    return cli.flags.e;
}

console.log();
Purifier.convertFolder(dir, opts, function(){
  console.log("\nYour project has been purified.");
});
