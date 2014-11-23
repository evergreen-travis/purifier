## -- Dependencies ------------------------------------------------------

Purifier = require '..'
fs       = require 'fs'
path     = require 'path'
should   = require 'should'
wrench   = require 'wrench'

## -- Tests -------------------------------------------------------------

describe 'Project Beautifier', ->

  before ->
    srcDir = path.resolve __dirname, "fixtures_backup"
    newDir = path.resolve __dirname, "fixtures"
    wrench.copyDirSyncRecursive srcDir, newDir,
      forceDelete : true
      # exclude     : /test1/g

  describe 'JS into COFFEE', ->

    it 'convert just code', ->
      output = Purifier._js2coffee """console.log(\"hello world\");"""
      output.should.eql """console.log "hello world\""""

    it 'convert a file', (done) ->
      filePath = path.resolve __dirname, 'fixtures/hello-world.js'
      Purifier.convertFile filePath, (output) ->
        output.should.eql """console.log "Hello world\""""
        done()

    it 'convert a file and write the result into other file', (done) ->
      filePath = path.resolve __dirname, 'fixtures/hello-world.js'
      Purifier.convertFile filePath, save:true, (output, route) ->
        fs.existsSync(route).should.eql true
        fs.existsSync(filePath).should.eql true
        done()

    it 'convert a file and remove the original', (done) ->
      filePath = path.resolve __dirname, 'fixtures/hello-world.js'
      Purifier.convertFile filePath, {save:true, remove:true}, (output, route) ->
        fs.existsSync(route).should.eql true
        fs.existsSync(filePath).should.eql false
        done()

  describe 'JSON into YAML', ->

    it 'convert just code', ->
      output = Purifier._json2yml """{"foo":"bar"}"""
      output.should.eql "---\n  foo: \"bar\"\n"

    it 'convert a file', (done) ->
      route = path.resolve __dirname, 'fixtures/hello-world.json'
      Purifier.convertFile route, (output) ->
        output.should.eql "---\n  foo: \"bar\"\n"
        done()

    it 'convert a file and write the result into other file', (done) ->
      filePath = path.resolve __dirname, 'fixtures/hello-world.json'
      Purifier.convertFile filePath, save:true, (output, route) ->
        fs.existsSync(route).should.eql true
        done()

  describe 'General', ->

    it 'try to convert a file that is not supported', ->
      (->
        Purifier._getConverter('hbs')
      ).should.throw("File extension 'hbs' is not supported.")

    it 'convert a folder', (done) ->
      route = path.resolve __dirname, 'fixtures/test1'
      Purifier.convertFolder route, {save:true, remove:true}, ->
        fileOne = path.resolve __dirname, 'fixtures/test1/hello-world_1.coffee'
        fileTwo = path.resolve __dirname, 'fixtures/test1/hello-world_2.coffee'
        fileThree = path.resolve __dirname, 'fixtures/test1/hello-world_3.coffee'
        fileFour = path.resolve __dirname, 'fixtures/test1/hello-world.yml'

        fs.existsSync(fileOne).should.eql true
        fs.existsSync(fileTwo).should.eql true
        fs.existsSync(fileThree).should.eql true
        fs.existsSync(fileFour).should.eql true
        done()
