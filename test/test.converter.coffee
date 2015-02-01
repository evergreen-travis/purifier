Purifier  = require './../lib/Purifier'
Converter = require './../lib/Converter'
path      = require 'path'
should    = require 'should'
wrench    = require 'wrench'

describe 'Converter ::', ->

  it 'convert just JS code into COFFEE', ->
    output = Converter.js2coffee """console.log(\"hello world\");"""
    output.should.eql "console.log \'hello world\'\n"

  it 'convert just JSON code into YAML', ->
    output = Converter.json2yml 'true'
    output.should.eql "---true\n"

  it 'get the converter for an extension', ->
    Converter.get('js').should.eql 'coffee'
    (->
      Converter.get('hbs')
    ).should.throw("File extension 'hbs' is not supported.")

  it 'check if exist a converter for an extension', ->
    Converter.isSupported('unicorns').should.eql false
    Converter.isSupported('js').should.eql true
