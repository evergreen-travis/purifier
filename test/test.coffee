## -- Dependencies ------------------------------------------------------

pb     = require '..'
fs     = require 'fs'
path   = require 'path'
should = require 'should'
wrench = require 'wrench'

## -- Tests -------------------------------------------------------------

describe 'Project Beautifier', ->

  before (done) ->
    srcDir = path.resolve __dirname, "fixtures_backup"
    newDir = path.resolve __dirname, "fixtures"
    wrench.copyDirRecursive(srcDir, newDir, {forceDelete: true}, done);

  describe 'JS into COFFEE', ->

    it 'convert just code', ->
      output = pb.js2coffee """console.log(\"hello world\");"""
      output.should.eql """console.log "hello world\""""

    it 'convert a file', (done) ->
      route = path.resolve __dirname, 'fixtures/hello-world.js'
      pb.convertFile route, (output) ->
        output.should.eql """console.log "Hello world\""""
        done()

    it 'convert a file and write the result into other file', (done) ->
      route = path.resolve __dirname, 'fixtures/hello-world.js'
      pb.convertFile route, save:true, (filePath) ->
        fs.existsSync(filePath).should.eql true
        done()

    it 'convert a file and remove the original', (done) ->
      route = path.resolve __dirname, 'fixtures/hello-world.js'
      pb.convertFile route, {save:true, remove:true}, (filePath) ->
        fs.existsSync(filePath).should.eql true
        fs.existsSync(route).should.eql false
        done()

  describe 'JSON into YAML', ->

    it 'convert just code', ->
      output = pb.json2yml """{"foo":"bar"}"""
      output.should.eql "---\n  foo: \"bar\"\n"

    it 'convert a file', (done) ->
      route = path.resolve __dirname, 'fixtures/hello-world.json'
      pb.convertFile route, (output) ->
        output.should.eql "---\n  foo: \"bar\"\n"
        done()

    it 'convert a file and write the result into other file', (done) ->
      route = path.resolve __dirname, 'fixtures/hello-world.json'
      pb.convertFile route, save:true, (filePath) ->
        fs.existsSync(filePath).should.eql true
        done()
