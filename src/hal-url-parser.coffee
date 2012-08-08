YUI.add 'hal-url-parser', (Y) ->
    #https://github.com/allmarkedup/jQuery-URL-Parser/tree/no-jquery
    # removed instant-function call
    purl = (undefined_) ->
        parseUri = (url, strictMode) ->
            str = decodeURI(url)
            res = parser[(if strictMode or false then "strict" else "loose")].exec(str)
            uri =
                attr: {}
                param: {}
                seg: {}

            i = 14
            uri.attr[key[i]] = res[i] or ""    while i--
            uri.param["query"] = {}
            uri.param["fragment"] = {}
            uri.attr["query"].replace querystring_parser, ($0, $1, $2) ->
                uri.param["query"][$1] = $2    if $1

            uri.attr["fragment"].replace fragment_parser, ($0, $1, $2) ->
                uri.param["fragment"][$1] = $2    if $1

            uri.seg["path"] = uri.attr.path.replace(/^\/+|\/+$/g, "").split("/")
            uri.seg["fragment"] = uri.attr.fragment.replace(/^\/+|\/+$/g, "").split("/")
            uri.attr["base"] = (if uri.attr.host then uri.attr.protocol + "://" + uri.attr.host + (if uri.attr.port then ":" + uri.attr.port else "") else "")
            uri
        getAttrName = (elm) ->
            tn = elm.tagName
            return tag2attr[tn.toLowerCase()]    if tn isnt `undefined`
            tn
        tag2attr =
            a: "href"
            img: "src"
            form: "action"
            base: "href"
            script: "src"
            iframe: "src"
            link: "href"

        key = [ "source", "protocol", "authority", "userInfo", "user", "password", "host", "port", "relative", "path", "directory", "file", "query", "fragment" ]
        aliases = anchor: "fragment"
        parser =
            strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*):?([^:@]*))?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/
            loose: /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*):?([^:@]*))?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/

        querystring_parser = /(?:^|&|;)([^&=;]*)=?([^&;]*)/g
        fragment_parser = /(?:^|&|;)([^&=;]*)=?([^&;]*)/g
        (url, strictMode) ->
            if arguments.length is 1 and url is true
                strictMode = true
                url = `undefined`
            strictMode = strictMode or false
            url = url or window.location.toString()
            data: parseUri(url, strictMode)
            attr: (attr) ->
                attr = aliases[attr] or attr
                (if attr isnt `undefined` then @data.attr[attr] else @data.attr)

            param: (param) ->
                (if param isnt `undefined` then @data.param.query[param] else @data.param.query)

            fparam: (param) ->
                (if param isnt `undefined` then @data.param.fragment[param] else @data.param.fragment)

            segment: (seg) ->
                if seg is `undefined`
                    @data.seg.path
                else
                    seg = (if seg < 0 then @data.seg.path.length + seg else seg - 1)
                    @data.seg.path[seg]

            fsegment: (seg) ->
                if seg is `undefined`
                    @data.seg.fragment
                else
                    seg = (if seg < 0 then @data.seg.fragment.length + seg else seg - 1)
                    @data.seg.fragment[seg]

    UrlParser = ->
    UrlParser::parseUrl = (theUrl = window?.location?.href) ->
        parser = purl()
        parser theUrl
    Y.namespace('hal').UrlParser = UrlParser
, '', requires: []
