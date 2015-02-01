Purifier  = require './../lib/Purifier'
Converter = require './../lib/Converter'
fs        = require 'fs'
path      = require 'path'
should    = require 'should'
wrench    = require 'wrench'

describe 'Purifier ::', ->

  before ->
    srcDir = path.resolve __dirname, "fixtures_backup"
    newDir = path.resolve __dirname, "fixtures"
    wrench.copyDirSyncRecursive srcDir, newDir,
      forceDelete : true

  it 'transform a file', (done) ->
    file = path.resolve __dirname, 'fixtures/hello-world.json'
    options = verbose: false
    Purifier.transformFile file, options, (output, counter, route) ->
      output.should.eql "---\n  foo: \"bar\"\n"
      done()

  it 'transform a file and write the result into other file', (done) ->
    file = path.resolve __dirname, 'fixtures/hello-world.js'
    options = save: true, verbose: false

    Purifier.transformFile file, options, (output, counter, route) ->
      fs.existsSync(route).should.eql true
      fs.existsSync(file).should.eql true

      file = path.resolve __dirname, 'fixtures/hello-world.json'
      Purifier.transformFile file, options, (output, counter, route) ->
        fs.existsSync(route).should.eql true
        fs.existsSync(file).should.eql true
        done()

  it 'transform a file, write the new and remove the original', (done) ->
    file = path.resolve __dirname, 'fixtures/hello-world.js'
    options = save: true, remove: true, verbose: false

    Purifier.transformFile file, options, (output, counter, route) ->
      fs.existsSync(route).should.eql true
      fs.existsSync(file).should.eql false
      done()

  it 'transform a folder ignoring common files', (done) ->
    file = path.resolve __dirname, 'fixtures/test1'
    options = save: true, remove: true, verbose: false

    Purifier.transformFolder file, options, ->
      fileOne = path.resolve __dirname, 'fixtures/test1/hello-world_1.coffee'
      fileTwo = path.resolve __dirname, 'fixtures/test1/hello-world_2.coffee'
      fileThree = path.resolve __dirname, 'fixtures/test1/hello-world_3.coffee'
      fileFour = path.resolve __dirname, 'fixtures/test1/hello-world.yml'

      fs.existsSync(fileOne).should.eql true
      fs.existsSync(fileTwo).should.eql true
      fs.existsSync(fileThree).should.eql true
      fs.existsSync(fileFour).should.eql true

      fileIgnoreOne = path.resolve __dirname, 'fixtures/test1/package.yml'
      fs.existsSync(fileIgnoreOne).should.eql false

      done()
