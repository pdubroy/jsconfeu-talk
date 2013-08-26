esprima = require 'esprima'
estraverse = require 'estraverse'

idgrep = (pattern, code, filename) ->
  lines = code.split '\n'
  ast = esprima.parse(code, parseOptions)
  estraverse.traverse ast,
    enter: (node, parent) ->
      if node.type == 'Identifier' and node.name.indexOf(pattern) >= 0
        loc = node.loc.start
        line = loc.line - 1
        console.log "#{ line }:#{ loc.column }: #{ lines[line] }"
      return
  return

parseOptions =
  loc: true
  range: true

idgrep 'hack', """
// This is a hack!
function hacky_function() {
  var hack = 3;
  return 'hacky string';
}
"""
