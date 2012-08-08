YUI.add 'hal-client', (Y) ->
    Y.namespace('hal') unless Y.hal?
, '@VERSION@', requires: [
    'hal-command'
    'hal-command-resource'
    'hal-link'
    'hal-link-parser'
    'hal-resource'
    'hal-resource-factory'
    'hal-resource-traversal-plugin'
    'hal-url-parser'
]
