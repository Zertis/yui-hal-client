_ = require 'underscore'
CoffeeScript  = require 'coffee-script'
fs = require('fs')
path = require('path')
express = require('express')
app = module.exports = express.createServer()

port = process.env.PORT or 8080

csTestCfg =
    scriptMatch: '/test/specs/:script(*).js'
    getCoffeeScriptFileName: (req) ->
        "./test/specs/#{req.params.script}.coffee"

testScript = (cfg) ->
    (req, res, next) ->
        filename = cfg.getCoffeeScriptFileName req
        fs.stat filename, (err, stats) =>
            return next unless stats? and stats.isFile()

            fs.readFile filename, 'utf8', (err, data) =>
                return next err if err?
                compiled = CoffeeScript.compile data, 
                    filename: filename
                res.header 'Content-Type', 'application/x-javascript'
                res.send compiled

app.configure(->

    app.use express.bodyParser()
    app.use(app.router)
    app.get csTestCfg.scriptMatch, testScript(csTestCfg)
    app.use(express.static("#{__dirname}/test"))
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
)

require('./lib/yui-config').middleware app, 
    yuiBase: 'js'
app.get '/', (req, res) ->
    res.redirect '/test/mocha-yui-runner.html'
#if(!module.parent)
app.listen(port)
console.log "Visit specs at http://localhost:#{app.address().port}"
