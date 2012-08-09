YUI.add 'hal-resource-factory', (Y) ->

    #cached regex for cleaning leading hashes and slashes
    routeStripper = /^[#\/]/

    ResourceFactory = (config) ->
        ResourceFactory.superclass.constructor.apply @, arguments
    ResourceFactory.NAME = 'resourceFactory'
    ResourceFactory.ATTRS = 
        rels: value: 
            commands: []
            links: []
        urlParser: valueFn: -> new Y.hal.UrlParser()
        urlRoutePart: value: 'relative'
        resourceFn: valueFn: -> Y.hal.Resource
        pushState: value: true
    
    Y.extend ResourceFactory, Y.Base,
        initializer: (cfg) ->
            @set 'urlRoutePart', 'fragment' unless @get('pushState')

        _assertDefinition: (def) ->
            def.url = @_urlFromHash def.url unless def.url?
            def.rels = def?.rels ? @get 'rels'
            def.href = def.url
            def.linkParser = def.linkParser ? @_getLinkParser()
            def

        _getLinkParser: ->
            parser = new Y.hal.LinkParser 
                resourceFactory: @
            parser


        _urlFromHash: (href) ->
            href = location.hash unless href?
            "/#{href.replace routeStripper, ''}"

        createLink: (cfg = {}) ->
            lnk = new Y.hal.Link cfg
            lnk
        createCommand: (cfg = {}) ->
            cmd = new Y.hal.CommandResource cfg
            cmd.plug Y.hal.ResourceTraversalPlugin,
                resourceFactory: @
            cmd


        ###*
        * creates resource using passed in definition
        *
        * @method createResource
        * @param {Object} [def] definition for resource
        *   @param {String} [def.url] the uri for the Resource
        *   @param {Object} [def.rels] `rels` to enable for _links; otherwise,
        *      the rels collection from this Factory
        *   @param {ResourceFactory} [def.resourceFactory] ResourceFactory to attach to the
        *      created Resource; otherwise, `this` Factory instance
        ###
        createResource: (def = {}) ->
            @_assertDefinition def
            resourceModel = @get 'resourceFn'
            res = new resourceModel def
            res.plug Y.hal.ResourceTraversalPlugin,
                resourceFactory: @
            res

        ###*
        * creates resource based on current url. note that
        * pushState enabled routing pulls from the url's 'relative' part;
        * otherwise, it looks at the 'fragment' (hash)
        * 
        * @method createRoutedResource
        ###
        createRoutedResource: (def = {}) ->
            parsed = @get('urlParser').parseUrl()

            def.url = parsed.attr @get('urlRoutePart')

            @createResource def

    Y.namespace('hal').ResourceFactory = ResourceFactory
                

, '', requires: [
    'base'
    'json'
    'oop'
    'hal-resource-traversal-plugin'
    'hal-url-parser'
    'hal-resource'
    'hal-link-parser'
]
