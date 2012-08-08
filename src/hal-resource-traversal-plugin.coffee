YUI.add 'hal-resource-traversal-plugin', (Y) ->
    ResourceTraversalPlugin = Y.Base.create 'resourceTraversalPlugin', Y.Plugin.Base, [],
        initializer: (cfg) ->
        follow: (rel) ->
            resources = @tryFollow rel
            return resources if resources.length > 0
            throw new Error "#{rel} is unknown resource" 
        # returns array of resource objects 
        # built from link href 
        tryFollow: (rel) ->
            host = @get 'host'
            factory = @get('resourceFactory')
            links = host.links?[rel] ? []
            links = [links] unless Y.Lang.isArray(links)
            return [] if links.length == 0
            defs = Y.Array.map links, (lnk) ->
                url: lnk.href ? lnk.get?('href')
            resources = []
            for def in defs
                resources.push factory.createResource(def)
            resources
    , 
        NS: 'traverse'
        ATTRS:
            resourceFactory: value: null
    Y.namespace('hal').ResourceTraversalPlugin = ResourceTraversalPlugin
,'', requires: [
    'base'
    'plugin'
    'collection'
    'json'
]
