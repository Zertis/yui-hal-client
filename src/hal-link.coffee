YUI.add 'hal-link', (Y) ->

    Link = Y.Base.create 'link', Y.Model, [], 
        initializer: ->
            #TODO dispatcher/eventing wireup?

        accept: (visitor) ->
            visitor.visitLink? @

        anchorHref: ->
            href = @get 'href'
            # anchor our href
            @setAttrs
                href: href.replace /^\//, '#'
    ,
        ATTRS:
            href: value: ''
            rel: value: ''
            title: value: ''
    Y.namespace('hal').Link = Link
, '', requires: ['app']
