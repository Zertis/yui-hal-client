YUI.add 'spec-hal-resource-traversal-plugin', (Y) ->
    describe 'ResourceTraversalPlugin', ->
        testHost = null
        beforeEach ->
            Host = Y.Base.create 'host', Y.Plugin.Host, [],
                links: 
                    self: [{ href: 'a1' }]
                    anArrayedResource: [
                        { href: 'd1' }
                        { href: 'd2' }
                    ]
                    anObjectResource:
                        href: 'd1'
                    aCommand: [{ href: 'c1' }]
        
                
            
            testHost = new Host()
            testHost.plug Y.hal.ResourceTraversalPlugin,
                resourceFactory: 
                    createResource: (def) -> def
        describe '#follow eligible link array', ->
            it 'should create new resource array using that rel', ->
                createdResources = testHost.traverse.follow 'anArrayedResource'
                createdResources.length.should.equal 2
                createdResources[0].url.should.equal 'd1'
                createdResources[1].url.should.equal 'd2'

                
        describe '#follow eligible link object', ->

            it 'should create new resource array using that rel', ->
                createdResources = testHost.traverse.follow 'anObjectResource'
                createdResources.length.should.equal 1
                createdResources[0].url.should.equal 'd1'

        describe '#host links regression test', ->
            testHost = null
            beforeEach ->
                Host = Y.Base.create 'host', Y.Plugin.Host, [],
                    links: 
                        self: [{ href: 'a1' }]
                        anArrayedResource: [
                            { href: 'd1' }
                            { href: 'd2' }
                        ]
                        anObjectResource:
                            href: 'd1'
                        aCommand: [{ href: 'c1' }]
            
                    
                
                testHost = new Host()
                factory = new Y.hal.ResourceFactory
                    rels:
                        links: '*'
                        commands: '*'
                testHost.plug Y.hal.ResourceTraversalPlugin,
                    resourceFactory: factory
            it 'should not touch host state', ->
                testHost.traverse.follow 'anArrayedResource'
                testHost.links.anArrayedResource.length.should.equal 2

, '', requires: [
    'hal-resource-traversal-plugin'
    'base'
    'plugin'
    'hal-resource-factory'
]

