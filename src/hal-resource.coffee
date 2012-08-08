YUI.add 'hal-resource', (Y) ->
    HAL_KEYS = ['_links', '_embedded']

    Resource = Y.Base.create 'resource', Y.Model, [], 

        initializer:  (cfg) ->
            @rels = cfg?.rels ? @rels
            @_setHref()
            @parseLinks @getAttrs()
            @_removeHAL()

        accept: (visitor) ->
            visitor.visitResource? @
            @_visitCollection @links, visitor
            @_visitCollection @commands, visitor

        parameterizeHref: (params = {}) ->
            href = @get 'href'
            sub = Y.substitute href, params, (k,v,name) =>
                encodeURIComponent(v)
            @set 'href', sub



        parse: (response) ->
            #we get raw response from YUI
            responseData = @_getValue(response)
            try
                clone = Y.clone responseData, true, (item, key) ->
                    #pluck out HAL_KEYS
                    return false if ~ HAL_KEYS.indexOf key
                    item
                @parseLinks responseData
                sef = responseData?._links?.self?.href
                clone.href = sef if sef?
                return clone
            catch err
                @fire 'error', 
                    type: 'parse'
                    error: err?.message ? err

        parseLinks: (data) ->
            parser = @get 'linkParser'
            unless parser?
                throw new Error "linkParser was not provided"
            parser.parseLinks @, data

        toJSON: ->
            data = Y.Model::toJSON.apply @, arguments
            parser = @get 'linkParser'
            comb = Y.merge data, parser.serializeLinks @
            delete comb.linkParser
            delete comb.rels
            comb
        _getValue: (response) ->
            return {} unless response?
            if response.responseText? and Y.Lang.isString(response.responseText)
                return Y.JSON.parse(response.responseText)
            response
        _removeHAL: ->
            @removeAttr '_links',  { silent:true }
            @removeAttr '_embedded', { silent: true }

        _setHref: (href) ->
            self = @
            href = href ? @get('_links')?.self?.href ? @get('href')
            @set 'href', href
            # bind to YUI instance for changes to this resource's location
            # HTTP 301
            Y.once "movedPermanently:#{href}", ({location}) =>
                return if location == self.get('href')
                self._setHref location

        _visitCollection: (col, visitor) ->
            for rel, vals of col
                arr = if Y.Lang.isArray(vals) then vals else [vals]
                (item.accept visitor) for item in arr
    , 
        ATTRS:
            href: value: ''
            title: value: ''
            rel: value: ''
            linkParser: value: null

    Y.namespace('hal').Resource = Resource
, '', requires: [
    'app'
    'json'
    'oop'
    'collection'
    'substitute'
]
