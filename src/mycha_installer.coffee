async = require 'async'
colors = require 'colors'
fsExtra = require 'fs-extra'
npm = require 'npm'
path = require 'path'


class MychaInstaller

  constructor: ({@cwd, @testHelperPath}) ->


  install: (done) ->
    async.series [
      @_installDependencies
      @_writeMychaConfig
      @_writeTestHelper
    ], done


  _installDependencies: (done) =>
    @_writeToStdout colors.bold('npm install --save-dev chai sinon sinon-chai'), lineBefore: yes
    npm.load 'save-dev': yes, (err) =>
      if err then return done err
      npm.commands.install @cwd, ['chai', 'sinon', 'sinon-chai'], done


  _writeMychaConfig: (done) =>
    fsExtra.outputFile(
      path.join(@cwd, 'mycha.coffee')
      """
      module.exports =

        # Environment variables to add to process.env when running mocha
        mochaEnv: {}

        # Default options to pass to mocha (can be overriden by command line options)
        mochaOptions:
          colors: yes
          compilers: 'coffee:coffee-script/register'
          reporter: 'dot'

        # Path patten used for finding tests (see https://github.com/isaacs/minimatch)
        testFilePattern: '**/*_{spec,test}.{coffee,js}'

        # Files to include before all tests
        testHelpers: [
          '#{@testHelperPath}'
        ]
      """
      (err) =>
        if err then return done err
        @_writeToStdout "#{colors.green 'create'} mycha.coffee", lineBefore: yes
        done())


  _writeTestHelper: (done) =>
    fsExtra.outputFile(
      path.join(@cwd, @testHelperPath)
      '''
      chai = require 'chai'
      sinon = require 'sinon'
      chai.use require 'sinon-chai'

      global.chai = chai
      global.expect = chai.expect
      global.sinon = sinon

      process.env.NODE_ENV = 'test'
      '''
      (err) =>
        if err then return done err
        @_writeToStdout "#{colors.green 'create'} #{@testHelperPath}", lineAfter: yes
        done())


  _writeToStdout: (message, {lineAfter, lineBefore}) ->
    str = ''
    str += '\n' if lineBefore
    str += "#{message}\n"
    str += '\n' if lineAfter
    process.stdout.write str, 'utf8'


module.exports = MychaInstaller
