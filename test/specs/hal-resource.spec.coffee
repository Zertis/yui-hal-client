YUI.add 'spec-hal-resource', (Y) ->

    describe 'Resource', ->
        sut = null
        linkParser = new Y.hal.LinkParser()
        describe '#init', ->
            it 'should exist', ->
                Y.hal.Resource.should.exist

        describe '#initialize with HAL', ->
            modelsData = null
            parsercore = null
            linksParsed = false
            factorycore = null
            embedded1 = null

            beforeEach ->
                embedded1 =
                    _links:
                        self:
                            href: 'a1/embedded'
                    name: 'otherRes'

                attrs =
                    rels:
                        links: ['anotherUrl']
                        commands: ['aCommand']
                    _links: 
                        self: { href: 'a1' }
                        anotherUrl: [{ href: 'd1' }]
                        aCommand: [{ href: 'c1', method: 'post' }]
                    _embedded:
                            col: [ embedded1 ]
                    linkParser: linkParser
                
                sut = new Y.hal.Resource attrs


            it 'should get url from self link', ->
                sut.get('href').should.equal 'a1'

            it 'should parse links', ->
                sut.links['anotherUrl'].should.exist
                sut.links['anotherUrl'][0].get('href').should.equal 'd1'
            it 'should parse commands', ->
                sut.commands['aCommand'].should.exist
                sut.commands['aCommand'][0].get('href').should.equal 'c1'
                        

            it 'should remove HAL fields', ->
                sut.get('_links')?.should.be.false
                sut.get('_embedded')?.should.be.false

            xit 'should create embedded resource collections', ->
                sut.embedded['col'].length.should.equal 1
                sut.embedded['col'][0].url.should.equal 'a1/embedded'
                sut.embedded['col'][0].get('name').should.equal 'otherRes'

        describe '#HTTP 301', ->
            beforeEach () ->
                sut = new Y.hal.Resource
                    _links: self: href: '/here/1'
                    linkParser: linkParser
                sut.get('href').should.equal '/here/1'

            it 'should update its location', (done) ->
                sut.after 'hrefChange', ->
                    sut.get('href').should.equal '/there/2'
                    done()
                Y.fire 'movedPermanently:/here/1',
                    location: '/there/2'

        describe '#load success', ->
            linksParsed = false
            loadEvent = null
            xhr = null
            beforeEach ->

                sut = new Y.hal.Resource
                    linkParser: linkParser

                sut.sync = (action, opts, cb) ->
                    cb null, 
                        _links:  self: href: 'meh' 
                        _embedded: other: [ { self: { href: 'meh2' }}]
                        some: 'data'

                sut.on 'load', (e) ->
                    loadEvent = e
                sut.load()
                

            it 'should derive url from self _link', ->
                sut.get('href').should.equal 'meh'

            it 'should parse links', ->
                sut.links.should.exist

            it 'should trigger load event', ->
                loadEvent.should.exist

            it 'should not set hal _links and _embedded', ->
                sut.get('_links')?.should.be.false
                sut.get('_embedded')?.should.be.false

            it 'should leave resource data alone', ->
                sut.get('some').should.equal 'data'
        describe '#toJSON', ->
            it 'should include links and commands', ->
                sut = new Y.hal.Resource
                    id: '123'
                    eeny: 'meeny'
                    miny: 'moe'
                    rel: 'prev'
                    title: 'mike'
                    href: '/path'
                    linkParser: linkParser

                sut.links =
                    rel1: [ { toJSON: -> 'rel1a'}, {toJSON: -> 'rel1b'}]
                    rel2: [ { toJSON: -> 'rel2a'}, {toJSON: -> 'rel2b'}]
                sut.commands =
                    cmd1: [ { toJSON: -> 'cmd1a'}, {toJSON: -> 'cmd1b'}]
                    cmd2: [ { toJSON: -> 'cmd2a'}, {toJSON: -> 'cmd2b'}]
                data = sut.toJSON()
                data.should.eql
                    id: '123'
                    eeny: 'meeny'
                    miny: 'moe'
                    href: '/path'
                    title: 'mike'
                    rel: 'prev'
                    _links:
                        rel1: ['rel1a', 'rel1b']
                        rel2: ['rel2a', 'rel2b']
                    _commands:
                        cmd1: ['cmd1a', 'cmd1b']
                        cmd2: ['cmd2a', 'cmd2b' ]

        describe '#parameterizeHref', ->
            it 'should parameterize href with provided obj', ->
                sut = new Y.hal.Resource
                    id: '123'
                    href: '/path?with={p}&to={q}'
                    title: 'par'
                    rel: 'par'
                    linkParser: linkParser
                sut.parameterizeHref { p: 'ppp', q: 'qqq'}
                sut.get('href').should.equal '/path?with=ppp&to=qqq'

            it 'should encode parameterized href with provided obj', ->
                sut = new Y.hal.Resource
                    id: '123'
                    href: '/path?with={p}&to={q}'
                    title: 'par'
                    rel: 'par'
                    linkParser: linkParser
                sut.parameterizeHref { p: 'p pp', q: 'q qq'}
                sut.get('href').should.equal '/path?with=p%20pp&to=q%20qq'



, '', requires: [
    'hal-resource'
    'hal-link-parser'
]
