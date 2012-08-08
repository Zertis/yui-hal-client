YUI.add 'spec-hal-command', (Y) ->
    describe 'Command', ->
        sut = null
        describe '#init', ->
            it 'should exist', ->
                Y.hal.Command.should.exist

        describe '#initialize', ->

            beforeEach ->
                sut = new Y.hal.Command()

            it 'should have defaults', ->
                sut.get('method').should.equal ''
                sut.get('href').should.equal ''
                sut.get('rel').should.equal ''
                sut.get('title').should.equal ''

        describe '#parse', ->
            parsed = null

            beforeEach ->
                sut = new Y.hal.Command()
                
                parsed = sut.parse
                    responseText: Y.JSON.stringify({form:{bite:'me'}})

            it 'should use attrs from form node', ->
                parsed.bite.should.equal 'me'


        describe '#activate with rel defined', ->
            commandName = null
            fetched = false
            fired = false
            arg = null

            beforeEach ->
                sut = new Y.hal.Command
                    rel: 'eatMyShorts'
                sut.on 'command:activated', ({rel, cmd}) ->
                    commandName = rel
                    fired = true
                    arg = cmd

                sut.load = (opts, cb) ->
                    fetched = true
                    cb null
                sut.activate()

            it 'should pass args', ->
                commandName.should.equal 'eatMyShorts'
                arg.should.eql sut

            it 'should fetch form', ->
                fetched.should.be.true

            it 'should trigger event based on rel upon success', ->
                fired.should.be.true

        describe '#activate with rel undefined', ->
            action = null

            beforeEach ->
                sut = new Y.hal.Command()
                action = -> sut.activate()
            it 'should throw', ->
                action.should.throw Error

        describe '#execute CREATE resulting in location', ->
            xhr = null
            requests = null
            executingTriggered = false
            beforeEach () ->
                requests = []
                sut = new Y.hal.Command 
                    href: '/my/resource/commands/doThis'
                    rel: 'doThis'
                    transport: 'rest'

                sut.on 'executing', ->
                    executingTriggered = true

                xhr = sinon.useFakeXMLHttpRequest()
                xhr.onCreate = (cur) -> requests.push cur
            afterEach ->
                xhr.restore()

            it 'should should fire movedPermanently event (301) upon custom 248 status', (done)->
                Y.on 'movedPermanently:/my/resource', ({cmd}) ->
                    done()
                sut.execute()
                requests[0].respond 248, { 
                    'Content-Type': 'application/json' 
                    'Location': '/didThat/123'
                }, ""

        describe '#execute rest', ->
            xhr = null
            requests = null
            executingTriggered = false
            beforeEach () ->
                requests = []
                sut = new Y.hal.Command 
                    href: '/my/resource/commands/doThis'
                    rel: 'doThis'
                    transport: 'rest'


                sut.on 'executing', ->
                    executingTriggered = true

                xhr = sinon.useFakeXMLHttpRequest()
                xhr.onCreate = (cur) -> requests.push cur
            afterEach ->
                xhr.restore()

            it 'should POST to resource core', ->
                sut.execute()
                requests.length.should.equal 1
                requests[0].url.should.equal '/my/resource/commands/doThis'


            it 'should should trigger executed event on success', (done)->
                sut.on 'doThis:executed', ({cmd}) -> 
                    cmd.should.eql sut
                    done()
                sut.execute()
                requests[0].respond 200, { 'Content-Type': 'application/json' }, ""

            it 'should trigger executing event', ->
                sut.execute()
                executingTriggered.should.be.true

        describe '#execute bad request', ->
            xhr = null
            requests = null
            e = null
            beforeEach ->
                requests = []
                sut = new Y.hal.Command 
                    href: '/my/resource'
                    rel: 'doThis'
                    transport: 'rest'

                xhr = sinon.useFakeXMLHttpRequest()
                xhr.onCreate = (cur) -> requests.push cur
            afterEach ->
                xhr.restore()

            it 'should trigger errors event', (done) ->
                sut.on 'executionError', (e) -> 
                    e.errors.should.eql ['oops']
                    done()
                sut.execute()
                requests[0].respond 400,{}, Y.JSON.stringify {errors: ['oops']}

, '', requires: ['hal-command', 'json']
