"use strict"

async = require 'async'
union = require 'array-union'
list  = require './Blacklist.data'

module.exports = class Blacklist

  @is: (file, cb) ->
    do (file, list, cb) ->
      async.detect list, (exclude, c) ->
        c((new RegExp exclude, "ig").test file)
      , (result) -> cb(not Boolean(result))

  @get: ->
    list

  @size: ->
    list.length

  @set: (newList) ->
    list = newList

  @add: ->
    @set(union(@get(), arguments[0]))
