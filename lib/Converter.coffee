"use strict"

js2coffee = require 'js2coffee'
json2yaml = require 'json2yaml'

module.exports = class Converter

  @_SUPPORTED_EXTENSIONS:
    'js'  : 'coffee'
    'json': 'yml'

  @js2coffee: (content, options)->
    js2coffee.build(content, options).code

  @json2yml: (content)->
    json2yaml.stringify(JSON.parse(content))

  @isSupported: (extension) ->
    @_SUPPORTED_EXTENSIONS[extension]?

  @get: (extension) ->
    @_SUPPORTED_EXTENSIONS[extension] or
    throw new Error "File extension '#{extension}' is not supported."
