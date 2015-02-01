File   = require './../lib/File'
path   = require 'path'
should = require 'should'
wrench = require 'wrench'

describe 'File ::', ->

  it 'remove filepaths that are in blacklist', (done) ->
    files = ["package.json", "unicorns.json", "io.js"]

    File.sanetizeFromBacklist files, (newFiles) ->
      newFiles.length.should.eql 2
      done()

  it 'remove filepaths from extensions', (done) ->
    files = ["package.json", "unicorns.json", "io.js"]
    allowExtensions = ["js"]

    File.sanetizeFromExtension files, allowExtensions, (newFiles) ->
      newFiles.length.should.eql 1
      done()
