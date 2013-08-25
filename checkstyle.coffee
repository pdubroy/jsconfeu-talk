# A simple JavaScript style checker.

esprima = require 'esprima'
estraverse = require 'estraverse'
_ = require 'underscore'

# Style checks to perform for the various node types.
# Each checking function returns an Array of errors, where each error is an
# object with properties 'location' and 'message'.
checks =
  VariableDeclaration: (node) ->
    errors = _.map node.declarations, (decl) ->
      # Disallow hacker_style variable names.
      if decl.id.name.indexOf('_') >= 0
        return err =
          location: decl.loc
          message: 'Use camelCase for variable names, not hacker_style.'
    _.compact errors

# Performs style checks on `code` and reports any errors that are found.
checkStyle = (code, filename) ->
  ast = esprima.parse(code, parseOptions)
  errors = []
  estraverse.traverse ast,
    enter: (node, parent) ->
      if checks[node.type]
        errors = errors.concat checks[node.type](node, parent)
  formatErrors(code, errors, filename)

# Takes a list of errors found by `checkStyle`, and returns a list of
# human-readable error messages.
formatErrors = (code, errors, filename) ->
  _.map errors, (e) ->
    loc = e.location.start
    prefix =
      if filename? "#{ filename }:#{ loc.line }:#{ loc.column }"
      else "Line #{ loc.line }, column #{ loc.column }"
    "#{ prefix }: #{ e.message }"

# Specifies the parse options for the Esprima parser.
parseOptions =
  loc: true  # Nodes include line- and column-based location info
  range: true  # Nodes have an index-based location range (array)

# A quick test to make sure things work.
console.log checkStyle """
var foo = bar;
var this_is_bad = 3;
function blah() {
  return function x() { var oops_another_one; }
}
"""