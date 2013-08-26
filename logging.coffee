# A script which tranforms JavaScript source code by adding logging calls at
# the entry and exit of every function.

escodegen = require 'escodegen'
esprima = require 'esprima'
estraverse = require 'estraverse'
_ = require 'underscore'

parse = esprima.parse

addLogging = (code) ->
  ast = parse code
  estraverse.traverse ast,
    leave: (node, parent) ->
      if node.type in ['FunctionDeclaration', 'FunctionExpression']
        wrapFunctionBody(node, getBeforeCode node, getAfterCode node)
  prelude = "var _ = require('underscore'), describeArgs = #{ describeArgs.toString() };"
  prelude + escodegen.generate ast

# Return a string with the code to insert at the beginning of the function
# represented by `node`.
getBeforeCode = (node) ->
  name = node?.id?.name ? '<anonymous function>'
  paramNames = ("'#{ x }'" for x in _.pluck(node.params, 'name')).join ', '
  describeArgs = "describeArgs([#{ paramNames }], arguments)"
  "console.log('Entering #{ name }(' + #{ describeArgs } + ')');"

# Return a string with the code to insert at the end of the function
# represented by `node`.
getAfterCode = (node) -> ''

# Take a FunctionDeclaration or FunctionExpression node, and wrap its body
# with `beforeCode` and `afterCode`.
wrapFunctionBody = (node, beforeCode, afterCode) ->
  beforeNodes = if beforeCode? then parse(beforeCode).body else []
  afterNodes = if afterCode? then parse(afterCode).body else []
  node.body.body = beforeNodes.concat(node.body.body, afterNodes)

# Returns a string describing the actual argument values that were passed to
# a function.
describeArgs = (parameterNames, values) ->
  names = ("#{ name }=" for name in parameterNames)
  formatValue = (v) -> if typeof(v) == 'string' then "'#{ v }'" else v
  ("#{ name ? '' }#{ formatValue(val) }" for [name, val] in _.zip(names, values)).join(', ')

console.log addLogging """
function foo(a, b) {
    var x = 'blah';
    var y = (function () {
        return 3;
    })();
}
foo(1, 'wut', 3)
"""

