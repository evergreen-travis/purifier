## -- Dependencies --------------------------------------------------------

js2coffee        = require 'js2coffee'
json2yaml        = require 'json2yaml'
path             = require 'path'
fs               = require 'fs'
readdirRecursive = require 'recursive-readdir'
## -- Class ---------------------------------------------------------------

class ProjectBeautifier

  js2coffee: (content, options)->
    content = JSON.stringify content if typeof content is 'object'
    js2coffee.build(content, options)

  json2yml: (content)-> json2yaml.stringify(JSON.parse(content))

  convertFile: (route, options, cb) ->
    if arguments.length is 2
      cb = options
      options = {}

    extOrig = path.extname route
    extDist = @_getConverter extOrig

    fs.readFile route, "utf8", (err, data) =>
      throw new Error err  if err

      converter = @["#{extOrig.substr(1)}2#{extDist.substr(1)}"]

      @_showVerboseMessage(route, extOrig, extDist) if @_VERBOSE

      _finally = =>
        if options.save
          route = @_changeExtension(route, extOrig, extDist)
          @saveFile route, converter(data), cb
        else
          cb(converter(data))

      return @removeFile route, _finally if options.remove
      _finally()

  convertFolder: (route, options, cb) ->
    if arguments.length is 2
      cb = options
      options = {}

    @readFolder route, options, (files) ->
      # TODO: TO IMPLEMENT!
      console.log files

  readFolder: (route, options, cb) ->

    readdirRecursive route, (err, files) =>

      excludes = @_EXCLUDE.DIR.concat(@_EXCLUDE.FILE)

      for exclude in excludes
        re = new RegExp(exclude,"ig")
        for file, index in files
          files.splice(index, 1) if re.test(file)

      if err then throw new Error err else cb files

  saveFile: (route, content, cb) ->
    fs.writeFile route, content, (err) ->
      if err then throw new Error err else cb route

  removeFile: (route, cb) ->
    fs.unlink route, (err) ->
      if err then throw new Error err else cb route

  ## -- Private -----------------------------------------------------------

  _VERBOSE: false

  _EXCLUDE:
    DIR: ['node_modules']
    FILE: ['package.json']

  _changeExtension: (route, origin, destination) ->
    routePath = route.split "."
    routePath[routePath.length-1] = destination.substr(1)
    routePath.join(".")

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
