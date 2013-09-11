# A simple JavaScript style checker.

_ = require 'underscore'
esprima = require 'esprima'
estraverse = require 'estraverse'

# Performs style checks on `code` and reports any errors that are found.
checkStyle = (code, filename) ->
  ast = esprima.parse(code, parseOptions)
  errors = []
  estraverse.traverse ast,
    enter: (node, parent) ->
      if node.type == 'VariableDeclaration'
        checkVariableNames(node, errors)
  formatErrors(code, errors, filename)

# Checks that all variable names in a VariableDeclaration node are
# in camelCase, not hacker_style.
checkVariableNames = (node, errors) ->
  _.each node.declarations, (decl) ->
    if decl.id.name.indexOf('_') >= 0
      errors.push
        location: decl.loc
        message: 'Use camelCase for variable names, not hacker_style.'

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