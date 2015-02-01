"use strict"

chalk   = require 'chalk'
figures = require 'figures'

module.exports = class Logger

  @print: (file, endExtension) ->
    file = file.substr(process.cwd().length + 1)
    console.log """
    #{file} #{chalk.green(figures.arrowRight)} \
    #{chalk.bold(endExtension)} #{chalk.green("purified")}."""
