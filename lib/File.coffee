"use strict"

fs        = require 'fs'
path      = require 'path'
recursive = require 'recursive-readdir'
async     = require 'async'
Blacklist = require './Blacklist'

module.exports = class File

  @read: (file, options, cb) ->
    if arguments.length is 2
      cb = options
      options = 'utf8'
    fs.readFile file, options, cb

  @readRecursive: (file, cb) ->
    recursive file, cb

  @write: (file, content, cb) ->
    fs.writeFile file, content, cb

  @remove: (file, cb) ->
    fs.unlink file, cb

  @getExtension: (file) ->
    (path.extname file).substr(1)

  @changeExtension: (file, newExtension) ->
    file = file.split "."
    file[file.length-1] = newExtension
    file.join "."

  @getRelativePath: (from=process.cwd(), to) ->
    path.relative(process.cwd(), from)

  @sanetizeFromBacklist: (files, cb) ->
    async.filter files, (file, c) =>
      Blacklist.is @getRelativePath(file), c
    , cb

  @sanetizeFromExtension: (files, extensions, cb) ->
    _isIncluded = (file, extensions, cb) =>
      fileExtension = @getExtension(file)
      async.detect extensions, (extension, c) ->
        c((new RegExp fileExtension, "ig").test extension)
      , (result) -> cb(Boolean(result))

    async.filter files, (file, c) ->
      _isIncluded file, extensions, c
    , cb
