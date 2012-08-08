_ = require 'underscore'
CoffeeScript  = require 'coffee-script'
fs = require('fs')
path = require('path')
express = require('express')
app = module.exports = express.createServer()

port = process.env.PORT or 3000

app.configure(->

    app.use express.bodyParser()
    app.use(app.router)
    app.use(express.static("#{__dirname}"))
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
)

require('./lib/yui-config').middleware app, 
    yuiBase: 'js'

app.get '/', (req, res) ->
    res.redirect '/index.html'

(require('./lib/hal-client')).middleware app
#if(!module.parent)
app.listen(port)
console.log "Visit specs at http://localhost:#{app.address().port}"
