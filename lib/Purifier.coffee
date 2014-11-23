## -- Dependencies --------------------------------------------------------

fs               = require 'fs'
path             = require 'path'
Args             = require 'args-js'
async            = require 'async'
js2coffee        = require 'js2coffee'
json2yaml        = require 'json2yaml'
arrayUnion       = require 'array-union'
readdirRecursive = require 'recursive-readdir'

## -- Class ---------------------------------------------------------------

class Purifier

  convertFile: ->
    args = Args([
      {route : Args.STRING   | Args.Required                     }
      {opts  : Args.OBJECT   | Args.Optional, _default: {}       }
      {cb    : Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    extOrig = path.extname args.route
    try
      extDist = @_getConverter extOrig
      @_showVerboseMessage(args.route, extOrig, extDist) if @_VERBOSE
    catch e
      return args.cb(e)

    async.waterfall [
      (cb) ->
        fs.readFile args.route, "utf8", cb
      (data, cb) =>
        converter = @["_#{extOrig.substr(1)}2#{extDist.substr(1)}"]
        cb(null, converter(data))
      (data, cb) ->
        if args.opts.remove
          fs.unlink args.route, (err) -> cb(err, data)
        else cb null, data
      (data, cb) =>
        if args.opts.save
          writePath = @_changeExtension(args.route, extOrig, extDist)
          fs.writeFile writePath, data, (err) -> cb(err, data, writePath)
        else
          cb null, data
    ], (err, output, filePath) ->
      throw err if err
      args.cb(output, filePath)

  convertFolder: ->
    args = Args([
      {route : Args.STRING   | Args.Required                     }
      {opts  : Args.OBJECT   | Args.Optional, _default: {}       }
      {cb    : Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    async.waterfall [
      (cb) ->
        readdirRecursive route, cb
      (files, cb) ->
        excludes = arrayUnion @_EXCLUDES, options.excludes or []
        files = @_sanetizeRoutes(files, excludes)
        ## TODO convertFile for file in files recursively
        console.log files


    ], (err, output, filePath) ->
      throw err if err
      args.cb(output, filePath)

  ## -- Private -----------------------------------------------------------

  _VERBOSE: false
  _EXCLUDES: ['package.json', 'node_modules']

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

  _sanetizeRoutes: (routes, excludes) ->
    routes.filter (route) ->
      isNotAlready = true
      for exclude in excludes
        isInBlacklist = (new RegExp exclude, "ig").test route
        if isInBlacklist
          isNotAlready = false
          break
      isNotAlready

## -- Exports -------------------------------------------------------------

exports = module.exports = Purifier
