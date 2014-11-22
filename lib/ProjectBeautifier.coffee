## -- Dependencies --------------------------------------------------------

js2coffee        = require 'js2coffee'
json2yaml        = require 'json2yaml'
path             = require 'path'
fs               = require 'fs'
readdirRecursive = require 'recursive-readdir'

## -- Class ---------------------------------------------------------------

class ProjectBeautifier

  convertFile: (route, options = {}, cb) ->
    if arguments.length is 2 then cb = options; options = {}

    extOrig = path.extname route
    extDist = @_getConverter extOrig

    fs.readFile route, "utf8", (err, data) =>
      throw err if err
      converter = @["_#{extOrig.substr(1)}2#{extDist.substr(1)}"]
      @_showVerboseMessage(route, extOrig, extDist) if @_VERBOSE
      newData = converter(data)

      _saveOrPrint = =>
        if options.save
          route = @_changeExtension(route, extOrig, extDist)
          fs.writeFile route, newData, (err) ->
            throw err if err
            cb(newData, route)
        else
          cb(newData)

      if options.remove
        fs.unlink route, (err) -> if err then throw err else _saveOrPrint()
      else
        _saveOrPrint()

  ## -- Private -----------------------------------------------------------

  _VERBOSE: false

  _EXCLUDE:
    DIR: ['node_modules']
    FILE: ['package.json']

  _changeExtension: (route, origin, destination) ->
    routePath = route.split "."
    routePath[routePath.length-1] = destination.substr(1)
    routePath.join "."

  _js2coffee: (content, options)-> js2coffee.build(content, options)
  _json2yml: (content)-> json2yaml.stringify(JSON.parse(content))

  _getConverter: (ext) ->
    switch ext
      when '.js' then '.coffee'
      when '.json' then '.yml'
      else throw new Error "File extension '#{ext}' is not supported."

  _showVerboseMessage: (route, extOrig, extDist) ->
    origFilePath = route.substr(process.cwd().length)
    distFilePath = @_changeExtension(origFilePath, extOrig, extDist)
    console.log "#{origFilePath} into #{distFilePath}"

## -- Exports -------------------------------------------------------------

exports = module.exports = ProjectBeautifier
