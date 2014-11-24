## -- Dependencies --------------------------------------------------------

fs               = require 'fs'
path             = require 'path'
chalk            = require 'chalk'
async            = require 'async'
figures          = require 'figures'
Args             = require 'args-js'
js2coffee        = require 'js2coffee'
json2yaml        = require 'json2yaml'
arrayUnion       = require 'array-union'
readdirRecursive = require 'recursive-readdir'

## -- Class ---------------------------------------------------------------

class Purifier

  ###*
   * Convert a file into other file with different extension.
   * @param  {string} route path of the file.
   * @param  {object} opts  options of the conversion. can be:
   *  - remove: flag that indicate if the original file must be deleted.
   *  - save: flag to indicate if the new file must be saved.
   * @return {string} the data conversion.
   * @return {string} the new path of the file.
  ###
  convertFile: (route, test)->
    args = Args([
      {route : Args.STRING   | Args.Required                     }
      {opts  : Args.OBJECT   | Args.Optional, _default: {}       }
      {cb    : Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    extOrig = (path.extname args.route).substr(1)
    return args.cb?() unless @_isSupported(extOrig)
    extDist = @_getConverter extOrig
    @_showVerboseMessage(args.route, extOrig, extDist) if @_VERBOSE

    async.waterfall [
      (cb) ->
        fs.readFile args.route, "utf8", cb
      (data, cb) =>
        converter = @["_#{extOrig}2#{extDist}"]
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
          cb null, data, route
    ], (err, output, filePath) ->
      throw err if err
      args.cb(output, filePath)



  ###*
   * Convert a folder of files
   * @param  {string} route path of the file.
   * @param  {object} opts  options of the conversion. can be:
   *  - remove: flag that indicate if the original file must be deleted.
   *  - save: flag to indicate if the new file must be saved.
   *  - ignore: Indicate what files can be ignore.
   *  - ext: Indicate compatible extension in the conversion.
   * @return {string} the data conversion.
   * @return {string} the new path of the file.
  ###
  convertFolder: ->
    args = Args([
      {route : Args.STRING   | Args.Required                     }
      {opts  : Args.OBJECT   | Args.Optional, _default: {}       }
      {cb    : Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    async.waterfall [
      (cb) ->
        readdirRecursive args.route, cb
      (files, cb) =>
        ignore = arrayUnion @_DEFAULT_OPTS.IGNORE, args.opts.ignore or []
        @_sanetizeRoutes files, ignore, (routes) -> cb(null, routes)
      (files, cb) =>
        async.each files, (file, c) =>
          @convertFile file, args.opts, c
        , (output, filePath) -> cb(null)
    ], (err) ->
      throw err if err
      args.cb()

  ## -- Private -----------------------------------------------------------

  _VERBOSE: false

  _DEFAULT_OPTS:
    IGNORE: ['package.json', 'node_modules']
    EXT:
      'js': 'coffee'
      'json': 'yml'

  _changeExtension: (route, origin, destination) ->
    routePath = route.split "."
    routePath[routePath.length-1] = destination
    routePath.join "."

  _isSupported: (ext) -> @_DEFAULT_OPTS.EXT[ext]?

  _getConverter: (ext) ->
    @_DEFAULT_OPTS.EXT[ext] or
    throw new Error "File extension '#{ext}' is not supported."

  _js2coffee: (content, options)-> js2coffee.build(content, options)
  _json2yml: (content)-> json2yaml.stringify(JSON.parse(content))

  _showVerboseMessage: (route, extOrig, extDist) ->
    origFilePath = route.substr(process.cwd().length)
    dirname = path.dirname(origFilePath)
    console.log """
    #{dirname}#{chalk.dim(extOrig)} #{chalk.green(figures.arrowRight)} \
    #{chalk.bold(extDist)} #{chalk.green("purified")}"""

  _isValidRoute: (route, ignore, cb) ->
    async.detect ignore, (exclude, c) ->
      c((new RegExp exclude, "ig").test route)
    , (result) -> cb(not Boolean(result))

  _sanetizeRoutes: (routes, ignore, cb) ->
    async.filter routes, (route, c) =>
      @_isValidRoute route, ignore, c
    , cb

## -- Exports -------------------------------------------------------------

exports = module.exports = Purifier
