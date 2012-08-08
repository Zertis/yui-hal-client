YUI.add 'hal-link-parser', (Y) ->
    LinkParser = ->
        LinkParser.superclass.constructor.apply @, arguments
    LinkParser.NAME = 'linkParser'
    LinkParser.ATTRS = {}

    isCommand = Y.hal.CommandResource.isCommandLink
        
    Y.extend LinkParser, Y.Base,
        initializer: (cfg) ->

            @rels = cfg?.rels ? @rels
            @_assertSelf()
        linkFn: Y.hal.Link
        commandFn: Y.hal.CommandResource
        commands: {}
        links: {}
        rels: 
            links: ['self']
            commands: []

        parseLinks: (target = {}, response) ->
            theRels = target.rels ? @rels
            _links = @parseResponse(response)
            @_clear target.links
            @_clear target.commands
            target.commands = @_parseCommands theRels.commands, _links
            target.links = @_parseLinks theRels.links, _links
            target.url = _links?.self?.href unless target.url?
            target
        mapLinks: (rels, _links) ->
            results = []
            filtered = @_filter rels, _links
            Y.Object.each filtered, (val, rel) =>
                links = if Y.Lang.isArray(val) then val else [val]
                results = results.concat Y.Array.map links,  (link) ->
                    Y.merge {}, { rel: rel }, link
            Y.Array.filter results, (item) -> item?

        ###*
        * serializes the _links and _commands collections into JSON
        * @returns {Object} representing the `rel` to {Array} on each collection
        ###
        serializeLinks: (target) ->
            target = target ? @
            obj =
                _commands: @_toJson target.commands
                _links: @_toJson target.links

        ###* 
        * Looks for an entry `_links` either by parsing an
        * XHR response (looking at `responseText`) or
        * by looking at an object key
        ###
        parseResponse: (response) ->
            return {} unless response?
            if response.responseText? and Y.Lang.isString(response.responseText)
                obj = Y.JSON.parse(response.responseText)
                obj?._links ? {}
            response._links ? {}

        _assertSelf: ->
            rels = @rels ? { links: [], commands: [] }
            rels.links = [] unless rels.links
            unless Y.Lang.isString(rels?.links) or ~rels.links.indexOf 'self'
                rels.links.push 'self'
                @rels = rels
        _clear: (obj = {}) ->
            keys = Y.Object.keys obj
            Y.Array.each keys, (key) -> delete obj[key]
            # do not replace instance with new one..
            obj


        _filter: (rels=[], _links={}) ->
            # just return links if wildcard is passed
            return _links if Y.Lang.isString('rels') && rels=='*'
            
            filtered = {}
            for rel in Y.Object.keys _links
                filtered[rel] = _links[rel] if ~ rels.indexOf rel
            filtered


        ###* 
        * Query `_links` for NON-commands only found in the `rels` filter.
        * Note this does not change state of host.
        *
        * @param {Any} rels accepts string or array of rels for filter
        * @param {Object} _links HAL _links object
        * @return {Object} Returns filtered object
        ###
        _parseLinks: (rels, _links) ->
            return unless rels?
            eligibleLinks = Y.clone _links, true
            for rel, lnk of _links
                delete eligibleLinks[rel] if isCommand(lnk)
            lnks = @mapLinks rels, eligibleLinks
            results = {}
            Y.Array.each lnks, (lnk) =>
                link = new @linkFn lnk
                results[lnk.rel] = (results[lnk.rel]?=[]).concat [link]
            results

        ###* 
        * Query `_links` for COMMANDS only found in the `rels` filter.
        * Commands are commonly those with a 'method' attribute.
        * Note this does not change state of host.
        *
        * @param {Any} rels accepts string or array of rels for filter
        * @param {Object} _links HAL _links object
        * @return {Object} Returns filtered object
        ###
        _parseCommands: (rels, _links) ->
            return unless rels?
            eligibleLinks = Y.clone _links, true
            for rel, lnk of _links
                delete eligibleLinks[rel] unless isCommand(lnk)
            lnks = @mapLinks rels, eligibleLinks
            results = {}
            Y.Array.each lnks, (lnk) =>
                cfg = Y.merge lnk,
                    linkParser: @
                cmd = new @commandFn cfg
                results[lnk.rel] = (results[lnk.rel]?=[]).concat [cmd]
            results

        _toJson: (col) ->
            rel2list = {}
            for rel, item of col
                for model in item
                    rel2list[rel] = (rel2list[rel] ? []).concat model.toJSON()
            rel2list


    Y.namespace('hal').LinkParser = LinkParser

, '@VERSION@', requires: [
    'hal-command-resource'
    'hal-link'
    'base'
    'event'
    'collection'
    'oop'
    'json'
]
