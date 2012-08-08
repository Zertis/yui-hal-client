YUI.add 'spec-hal-link', (Y) ->
    describe 'Link', ->
        sut = null
        describe '#init', ->
            it 'should exist', ->
                Y.hal.Link.should.exist

        describe '#initialize with def href', ->
            beforeEach ->
                sut = new Y.hal.Link 
                    href: '/waiters/123'

            it 'should make href an anchor', ->
                sut.anchorHref()
                sut.get('href').should.equal '#waiters/123'
        describe '#initialize with anchored href', ->
            beforeEach ->
                sut = new Y.hal.Link 
                    href: '#waiters/123'

            it 'should not change href', ->
                sut.get('href').should.equal '#waiters/123'


, '', requires: ['hal-link']

                
