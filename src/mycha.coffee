Mocha = require 'mocha'
fs = require 'fs'
path = require 'path'
child = require 'child_process'

class Mycha
  constructor: (projectDir, options={}) ->
    @stdout = options.stdout or process.stdout
    @stderr = options.stdin or process.stderr
    @reporter = options.reporter or 'dot'
    @testDir = path.join projectDir, 'test'


  getTestFiles: ->
    files = []
    helper = (dir, files) ->
      for file in fs.readdirSync(dir)
        continue if file[0] == '.'
        filePath = path.resolve "#{dir}/#{file}"
        stat = fs.statSync filePath
        if stat.isFile()
          files.push filePath
        else if stat.isDirectory()
          helper filePath, files

    helper.call helper, @testDir, files
    files


  run: (callback) ->
    args = [
      # Set mocha options
      "--compilers coffee:coffee-script"
      "--reporter #{@reporter}"
      "--colors"

      # Include mycha test helper
      "#{__dirname}/helper.js"

      # Include files found in /test
      @getTestFiles().join(' ')
    ]

    childProcess = child.spawn "#{__dirname}/../node_modules/mocha/bin/mocha", args.join ' '
    childProcess.stdout.pipe @stdout
    childProcess.stderr.pipe @stderr
    childProcess.on 'exit', callback if callback


module.exports = Mycha
