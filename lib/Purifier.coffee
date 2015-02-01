"use strict"

async     = require 'async'
Args      = require 'args-js'
Converter = require './Converter'
File      = require './File'
Logger    = require './Logger'
Blacklist = require './Blacklist'

module.exports = class Purifier

  ###*
   * Convert a file into other file with different extension.
   * @param  {string} file path of the file.
   * @param  {object} opts  options of the conversion. can be:
   *  - remove: flag that indicate if the original file must be deleted.
   *  - save: flag to indicate if the new file must be saved.
   *  - verbose: true by default. print the operation in the CLI.
   * @return {string} the data conversion.
   * @return {string} the new path of the file.
  ###
  @transformFile: ->
    _options = {counter: 0, verbose: true}
    args = Args([
      {file : Args.STRING   | Args.Required                     }
      {opts : Args.OBJECT   | Args.Optional, _default: _options }
      {cb   : Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    startExtension = File.getExtension args.file
    return args.cb?() unless Converter.isSupported(startExtension)
    ++args.opts.counter
    endExtension = Converter.get startExtension

    Logger.print(args.file, endExtension) if args.opts.verbose

    async.waterfall [
      (cb) ->
        File.read args.file, cb
      (data, cb) ->
        converter = Converter["#{startExtension}2#{endExtension}"]
        cb(null, converter(data))
      (data, cb) ->
        if args.opts.remove
          File.remove args.file, (err) -> cb(err, data)
        else cb null, data
      (data, cb) ->
        if args.opts.save
          file = File.changeExtension(args.file, endExtension)
          File.write file, data, (err) ->
           cb(err, data, args.opts.counter, file)
        else
          cb null, data, args.opts.counter, file
    ], (err, data, counter, file) ->
      throw err if err
      args.cb(data, counter, file)



  ###*
   * Convert a folder of files
   * @param  {string} file path of the file.
   * @param  {object} opts  options of the conversion. can be:
   *  - remove: flag that indicate if the original file must be deleted.
   *  - save: flag to indicate if the new file must be saved.
   *  - ignore: Indicate what files can be ignore.
   *  - ext: Indicate compatible extension in the conversion.
   *  - verbose: true by default. print the operation in the CLI.
   * @return {string} the data conversion.
   * @return {string} the new path of the file.
  ###
  @transformFolder: ->
    _options = {extensions: [], verbose: true}
    args = Args([
      {file  : Args.STRING   | Args.Required                     }
      {opts  : Args.OBJECT   | Args.Optional, _default: _options }
      {cb    : Args.FUNCTION | Args.Optional, _default: undefined}
    ], arguments)

    Blacklist.add(args.opts.ignore) if args.opts.ignore?
    args.opts.extensions = [] unless args.opts.extensions?
    args.opts.counter = 0

    async.waterfall [
      (cb) ->
        File.readRecursive args.file, cb
      (files, cb) ->
        return cb(null, files) if args.opts.extensions.length is 0
        File.sanetizeFromExtension files, args.opts.extensions, (files) ->
          cb(null, files)
      (files, cb) ->
        File.sanetizeFromBacklist files, (files) ->
          cb(null, files)
      (files, cb) =>
        console.log files
        async.each files, (file, c) =>
          @transformFile file, args.opts, c
        , ->
          cb(null, args.opts.counter, files)
    ], (err, counter, files) ->
      throw err if err
      args.cb(counter, files)
