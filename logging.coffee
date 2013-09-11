# A script which tranforms JavaScript source code by adding logging calls at
# the entry and exit of every function.

escodegen = require 'escodegen'
esprima = require 'esprima'
estraverse = require 'estraverse'
_ = require 'underscore'

addLogging = (code) ->
  ast = esprima.parse code
  estraverse.traverse ast,
    leave: (node, parent) ->
      if node.type in ['FunctionDeclaration', 'FunctionExpression']
        wrapFunctionBody(node, getBeforeCode(node))
  prelude = "var _ = require('underscore'), describeArgs = #{ describeArgs.toString() };"
  prelude + escodegen.generate ast

# Return a string with the code to insert at the beginning of the function
# represented by `node`.
getBeforeCode = (node) ->
  name = if node.id then node.id.name else '<anonymous function>'
  paramNames = _.map(node.params, (p) -> "'#{ p.name }'").join ', '
  describeArgs = "describeArgs([#{ paramNames }], arguments)"
  "console.log('Entering #{ name }(' + #{ describeArgs } + ')');"

# Take a FunctionDeclaration or FunctionExpression node, and wrap its body
# with `beforeCode` and `afterCode`.
wrapFunctionBody = (node, beforeCode, afterCode) ->
  beforeNodes = if beforeCode? then esprima.parse(beforeCode).body else []
  afterNodes = if afterCode? then esprima.parse(afterCode).body else []
  node.body.body = beforeNodes.concat(node.body.body, afterNodes)

# Returns a string describing the actual argument values that were passed to
# a function.
describeArgs = (parameterNames, values) ->
  names = _.map(parameterNames, (name) -> "#{ name }=")
  formatValue = (v) -> if _.isString(v) then "'#{ v }'" else v
  _.map(_.zip(names, values), (each) ->
    "#{ each[0] ? '' }#{ formatValue(each[1]) }"
  ).join(', ')

console.log addLogging """
function foo(a, b) {
    var x = 'blah';
    var y = (function () {
        return 3;
    })();
}
foo(1, 'wut', 3)
"""

