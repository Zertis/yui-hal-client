{YUI} = require('yui')
CoffeeScript = require 'coffee-script'
Y = YUI(useSync:true).use 'oop', 'collection'
fs = require 'fs'
path = require 'path'
skip = [ 'application.coffee' ]

cached = null

compiled = {}

getContents = (file, module) ->
    contents = fs.readFileSync file, 'utf-8'
    if ~path.extname(file).indexOf 'coffee'
        contents = CoffeeScript.compile contents,
            filename: file
    compiled["#{module}"] = contents
    contents

readRequires = (contents) ->
    #first squish contents, removing CR, newline and whitespace
    flat = contents.replace /[\n\s\r]/g, ''
    #now extract our requires
    requiresRE = /requires\:\[(.*)\]/
    #finally get rid of quotes
    quotesTrimRE =  /['"]/g
    match = flat.match requiresRE
    #convert our requires string to an array
    trimmed =  RegExp.$1.replace(quotesTrimRE, '')
    requires = if trimmed == '' then [] else trimmed.split ','
    requires


###*
* creates yui cfg object, keyed by module name (using filename as convention)
* with `fullpath` {String} value and `requires` {Array}
* @param {String} basedir root directory containing physical files
* @param {Object} opts (optional)
*       @param {String} opts.yuiBase base path yui uses for loading, ie : '/js'
###
scrape = (basedir, opts = {}, callback=->) ->
    if Y.Lang.isFunction opts
        callback = opts
        opts = {}
    withoutLeadingSlash = (str) -> 
        if str.substring(0,1) == '/'
            return str.substring 1
        str
    opts.yuiBase = "/#{withoutLeadingSlash(opts.yuiBase ? '')}"
    #synchronous since this should only be done onk startup
    cfg = {}
    {sync} = require 'findit'
    files = sync basedir,  {}, (file, stat) =>
        module = path.basename(file).replace(path.extname(file), '')
        if stat.isFile()
            contents = getContents file, module
            unless ~ skip.indexOf(path.basename(file))
                fullpath = file.replace(basedir,'').replace(path.extname(file),'.js')
                fullpath = withoutLeadingSlash fullpath
                cfg[module] =
                    fullpath: fullpath
                    requires: readRequires contents
    Y.Object.each cfg, (val, key) =>
        withYUI =  "#{opts.yuiBase}/#{val.fullpath}".replace '//', '/'
        val.fullpath =  withYUI
    callback null, cfg

generate = (opts = {}, cb) ->
    cb null, cached if cached?
    basedir = path.resolve(__dirname, '..', 'src')
    scrape basedir, opts, (err, cfg) =>
        return cb err if err?
        serialized = JSON.stringify             
            modules: cfg
        cb null, "var yuiCfg = #{serialized}"

module.exports =
    middleware: (app, opts) ->
        #generate on app startup
        generate opts, (err, cfg) ->
            throw err if err? #break if problems
        app.get '/js/yui-cfg.js', (req, res, next) ->
            res.header 'Content-Type', 'application/x-javascript'
            generate opts, (err, cfg) ->
                res.send cfg
        app.get '/js/:script(*).js', (req, res, next) ->
            body = compiled[req.params.script]
            return next() unless body?
            res.header 'Content-Type', 'application/x-javascript'
            res.send body

    scrape: scrape
