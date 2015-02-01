Blacklist = require './../lib/Blacklist'
list      = require './../lib/Blacklist.data.json'
path      = require 'path'
should    = require 'should'
wrench    = require 'wrench'

describe 'Blacklist ::', ->

  it 'check for invalid route', (done) ->
    fileIgnoreOne = path.resolve __dirname, 'fixtures/test1/package.json'
    Blacklist.is fileIgnoreOne, (isValid) ->
      isValid.should.equal false
      done()

  it 'check for a valid route', (done) ->
    fileIgnoreOne = path.resolve __dirname, 'fixtures/test1/hello-world.json'
    Blacklist.is fileIgnoreOne, (isValid) ->
      isValid.should.equal true
      done()

  it 'extend the blacklist with new items', ->
    Blacklist.add(['.bowerrc'])
    size = list.length + 1
    Blacklist.size().should.equal size

