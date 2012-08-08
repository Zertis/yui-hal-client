YUI.add 'hal-command-resource', (Y) ->
    CommandResource = Y.Base.create 'commandResource', Y.hal.Resource, [Y.hal.Command],
        initializer: ->


        parse: (response) ->
            Y.hal.Resource::parse.apply @,[response]
            Y.hal.Command::parse.apply @, arguments

    CommandResource.isCommandLink = Y.hal.Command.isCommandLink

    Y.namespace('hal').CommandResource = CommandResource

, '@VERSION@', requires: [
    'base'
    'hal-resource'
    'hal-command'
]
