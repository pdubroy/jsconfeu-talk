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
      if node.type == 'FunctionDeclaration' or node.type == 'FunctionExpression'
        transformFunction node
  escodegen.generate ast

transformFunction = (node) ->
  name = if node.id? then node.id.name else '<anonymous function>'
  wrapFunctionBody(node, "console.log('Entering #{ name }()');")

# Take a FunctionDeclaration or FunctionExpression node, and wrap its body
# with `beforeCode` and `afterCode`.
wrapFunctionBody = (node, beforeCode, afterCode) ->
  beforeNodes = if beforeCode? then parse(beforeCode).body else []
  afterNodes = if afterCode? then parse(afterCode).body else []
  node.body.body = beforeNodes.concat(node.body.body, afterNodes)

console.log addLogging """
function foo() {
    var x = 'blah';
    var y = function () {
        return 3;
    };
}
"""
