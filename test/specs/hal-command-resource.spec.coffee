YUI.add 'spec-hal-command-resource', (Y) ->
    describe 'CommandResource', ->
        sut = null
        it 'should exist', ->
            Y.hal.CommandResource.should.exist
    
        describe '#parse with _links', ->
            parsed = null

            beforeEach ->
                sut = new Y.hal.CommandResource
                    linkParser: new Y.hal.LinkParser
                        resourceFactory: new Y.hal.ResourceFactory()
                    rels: 
                        links: '*'
                json = Y.JSON.stringify
                    form: 
                        bite: 'me'
                    _links: 
                        aRel: 
                            href: '/some/where'
                            title: 'meh'

                parsed = sut.parse
                    responseText: json

            it 'should use attrs from form node', ->
                parsed.bite.should.equal 'me'
            it 'should parse links', ->
                
                sut.links.aRel.should.exist
                sut.links.aRel.length.should.equal 1
                sut.links.aRel[0].get('title').should.equal 'meh'
                sut.links.aRel[0].get('href').should.equal '/some/where'


, '', requires: [
    'hal-command-resource'   
    'hal-link-parser'
    'json'
    'hal-resource-factory'
]
