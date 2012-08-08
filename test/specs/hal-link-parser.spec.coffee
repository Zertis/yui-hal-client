YUI.add 'spec-hal-link-parser', (Y) ->


    describe 'LinkParser', ->
        sut = null
        rels = null
        response = null
        beforeEach ->
            rels = 
                commands: [ 'doThis', 'doThat' ]
                links: ['waiters']
            response =
                _links:
                    self: 
                        href: '/me'
                    notYet:
                        href: '/not/yet'
                    doThis:
                        href: '/do/this'
                        method: 'post'
                    doThat:
                        href: '/do/that'
                        method: 'post'
                    waiters:
                        href: '/waiters'

        describe '#init', ->
            it 'should exist', ->
                Y.hal.LinkParser.should.exist

        describe '#parse _links with empty array', ->
            beforeEach ->
                response =
                    _links:
                        self: 
                            href: '/me'
                        empty: []
                sut = new Y.hal.LinkParser
                    rels: links: '*'

                @target = {}
                sut.parseLinks @target, response
            it 'should exclude empty links', ->
                expect(@target.links['empty']).to.be.undefined


        describe '#parse with filter', ->
            beforeEach ->
                @target = {}
                sut = new Y.hal.LinkParser
                    rels: rels
                    filter: true
                sut.parseLinks @target, response

            it 'should set url based on self link', ->
                @target.url.should.equal '/me'

            it 'should set _links in command registry', ->
                Y.Object.keys(@target.commands).length.should.equal 2
                @target.commands['doThis'].should.exist
                @target.commands['doThat'].should.exist

            it 'should set _links in links registry', ->
                Y.Object.keys(@target.links).length.should.equal 2
                @target.links['waiters'].should.exist
                @target.links['self'].should.exist

        describe '#parse command _links with wildcard filter', ->
            beforeEach ->
                @target = {}
                sut = new Y.hal.LinkParser
                    rels:
                        links: ['waiters']
                        commands: '*'
                sut.parseLinks @target, response

            it 'should set url based on self link', ->
                @target.url.should.equal '/me'

            it 'should set _links in command registry', ->
                Y.Object.keys(@target.commands).length.should.equal 2
                @target.commands['doThis'].should.exist
                @target.commands['doThat'].should.exist

            it 'should set _links in links registry', ->
                Y.Object.keys(@target.links).length.should.equal 2
                @target.links['waiters'].should.exist
                @target.links['notYet']?.should.be.false
                @target.links['self'].should.exist
        describe '#parse nonCommand _links with wildcard filter', ->
            beforeEach ->
                @target = {}
                sut = new Y.hal.LinkParser
                    rels:
                        links: '*'
                        commands: ['doThis', 'doThat']
                sut.parseLinks @target, response

            it 'should set url based on self link', ->
                @target.url.should.equal '/me'

            it 'should set _links in command registry', ->
                Y.Object.keys(@target.commands).length.should.equal 2
                @target.commands['doThis'].should.exist
                @target.commands['doThat'].should.exist

            it 'should set _links in links registry', ->
                Y.Object.keys(@target.links).length.should.equal 3
                @target.links['waiters'].should.exist
                @target.links['notYet'].should.exist
                @target.links['self'].should.exist
        describe '#parse (with filter) rel _links with array', ->
            beforeEach ->
                @target = {}
                rels = 
                    links: ['multi']
                response =
                    _links:
                        self: 
                            href: '/me'
                        multi: [
                            { href: '/a1', title: 'a1' }
                            { href: '/a2', title: 'a2' }
                        ]
                sut = new Y.hal.LinkParser
                    rels: rels
                    filter: true
                sut.parseLinks @target, response

            it 'should set url based on self link', ->
                @target.url.should.equal '/me'

            it 'shold set all _links in links registry', ->
                Y.Object.keys(@target.links).length.should.equal 2
                @target.links['multi'].should.exist
                @target.links['self'].should.exist
                Y.Object.keys(@target.links['multi']).length.should.equal 2
            it 'links arrays work', ->
                @target.links['multi'][0].get('title').should.equal 'a1'
                @target.links['multi'][1].get('title').should.equal 'a2'

        describe '#mapLinks', ->
            exists = null
            beforeEach ->
                @target = {}
                rels =  ['aCommand', 'anotherCommand']
                sut = new Y.hal.LinkParser() 
                _links = 
                    self: 
                        href: '/waiters'
                    aCommand:
                        href: '/waiters/aCommand'
                        method: 'get'
                    anotherCommand:
                        href: '/waiters/anotherCommand'
                        method: 'post'                      
                    notACommand:
                        href: '/waiters/somethingelse'
                parsed = sut.mapLinks rels, _links
                exists = (cmd) ->
                    Y.Array.some parsed, (l) ->
                        l.href == _links[cmd].href &&
                        l.rel == cmd &&
                        l.method == _links[cmd].method 

            it 'should filter models in rel registry', ->
                exists('aCommand').should.be.true
                exists('anotherCommand').should.be.true
                


, '', requires: [
    'hal-link-parser', 
    'collection'
]
