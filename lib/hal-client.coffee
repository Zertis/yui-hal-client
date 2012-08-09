Y = require('yui').YUI({useSync:true}).use 'collection', 'oop'
CoffeeScript = require 'coffee-script'
fs = require 'fs'
path = require 'path'
compiled = {}
module.exports.getCfg = getCfg = ->
        reqs = [
            'hal-command'
            'hal-command-resource'
            'hal-link'
            'hal-link-parser'
            'hal-resource'
            'hal-resource-factory'
            'hal-resource-traversal-plugin'
            'hal-url-parser'
        ]
        reqMods = {}
        modularize = (name) ->
            mod = {}
            reqMods[name] =
                fullpath: "/hal/#{name}.js"
        (modularize(req)) for req in reqs
        merged = Y.merge reqMods,
            hal: use: reqs
        return { modules: merged }
module.exports.middleware = (app) ->
    dirpath = path.join __dirname, '..', 'src'
    files = fs.readdirSync dirpath
    files.forEach (file) =>
        filename = path.basename(file).replace(path.extname(file), '')
        data = fs.readFileSync path.join(dirpath, file), 'utf8'
        compiled[filename] = CoffeeScript.compile data,
            filename: filename

    app.get '/hal/hal-cfg.js', (req, res, next) ->
        cfg = getCfg()
        res.header 'Content-Type', 'application/javascript'
        #send a json object
        res.send "var halCfg = #{JSON.stringify cfg}"

    app.get '/hal/:script(*).js', (req, res, next) ->
        res.header 'Content-Type', 'application/javascript;charset=utf-8'
        res.header 'Last-Modified', new Date().toUTCString()
        filename = req.params.script
        cached = compiled[filename]
        res.send cached





