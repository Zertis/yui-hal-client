YUI.add 'hal-command', (Y) ->
    getValue = (object, prop) ->
        return null unless object and object[prop]
        (if Y.Lang.isFunction(object[prop]) then object[prop]() else object[prop])

    class RestSync        
        buildUrl: ->
            "#{@get?('href') ? getValue(@, 'url')}"
        sync: (action, options, cb = ->) ->
            switch action
                when 'read'
                    return @form(options, cb)
                when 'save'
                    throw new Error("use 'execute' instead of 'save'")
                else
                    throw new Error("#{action} not supported.")
        form: (options, cb = ->) ->
            url = @buildUrl()
            unless url?
                throw new Error "url is required"
            thisUrl = "#{url}"

            Y.io thisUrl, 
                method: 'GET'
                headers:
                    'Accept': 'application/json'
                data: options.data ? {}
                on:
                    success: (tid, res) ->
                        cb null, res
                    failure: (tid, res) ->
                        msg = res.responseText
                        Y.log (msg ? 'no response'), 'error', 'ioSync'
                        cb new Error "#{res.status}:#{msg}"

        execute: (attrs) ->
            @setAttrs attrs
            @fire 'executing', 
                cmd: @
                attrs: attrs
            url = @buildUrl()
            rel = @get 'rel'
            self = @
            Y.io url,
                headers:
                    'Content-Type': 'application/json'
                data: Y.JSON.stringify @toJSON()
                method: 'POST'
                on: 
                    ###*
                    * custom `248` status
                    * can be returned to alert that the
                    * the parent resource href has changed.
                    * this is a hack to get around the 
                    * browser interception of 301 code
                    ###
                    success: (tx, res) ->
                        evName = "#{rel}:executed"
                        isMoved = false
                        location = (res?.getResponseHeader 'Location')
                        switch res.status
                            when 248
                                self.fire301 location
                                isMoved = true
                            when 204
                                evName = "#{rel}:deleted"
                                isMoved = !location?
                        self.fire evName, 
                            cmd: self
                            location:
                                isMoved: isMoved
                                href: location
                    failure: (tx, res) ->
                        msg = res.responseText
                        e =
                            errors: [new Error('there was an error on the last request')]
                        try
                            e = Y.JSON.parse res.responseText
                            Y.log Y.JSON.stringify(msg), 'error', 'hal-command execution error'
                        catch err
                            Y.log err, 'error', 'hal-command parse responseText'
                        finally    
                            #event args should have a property
                            #`errors` with an {Array} of errors
                            self.fire 'executionError', e
    Command = Y.Base.create 'command', Y.Model, [RestSync],

        initializer: ->
            @movedPermanentlyEvent = @publish "movedPermanently:#{@getParentResourceUrl()}",
                emitFacade: true
                broadcast: 1
            @activatedEvent = @publish "activated",
                emitFacade: true
                broadcast: 1


        accept: (visitor) ->
            visitor.visitCommand? @

        activate: ->
            @_assertActivatable()
            opts = {}
            @load opts, (err, response) =>
                e = 
                    rel: @get('rel')
                    cmd: @
                @transport = response?.transport
                @activatedEvent.fire
                    rel: @get 'rel'
                    cmd: @

        ###*
        * deactivate this command without side-effects
        ###
        cancel: ->
            #yes, this is American english
            @fire 'canceled',
                rel: @get 'rel'
                cmd: @

        ###* 
        * implement http 301 updates 
        ###
        fire301: (newLocation) ->
            return unless newLocation?
            @movedPermanentlyEvent.fire 
                location: newLocation
                cmd: @

        ###*
        * resource which 'owns' this command
        ###
        getParentResourceUrl: ->
            url = @buildUrl()
            url.replace "/commands/#{@get('rel')}", ''

        parse: (response) ->
            obj = Y.JSON.parse response?.responseText
            return null unless obj?
            obj.form ? obj

        url: ->
            @get 'href'

        _assertActivatable: ->
            rel = @get 'rel'
            throw new Error '"rel" attribute undefined' unless rel and rel != ''

    , 
        ATTRS:
            method: value: ''
            href: value: ''
            rel: value: ''
            title: value: ''
            transport: value: 'rest'
        isCommandLink: (lnk) ->
            return false unless lnk?
            return lnk?.method? unless Y.Lang.isArray(lnk)
            some = Y.Array.some lnk, (l) -> l.method?
            some

    Y.namespace('hal').Command = Command
, '', requires: [
    'app'
    'io'
    'json'
    'collection'
    'querystring'
]
