var escodegen = require('escodegen');
var esprima = require('esprima');
var estraverse = require('estraverse');
var _ = require('underscore');

function addLogging(code) {
  var ast = esprima.parse(code);
  estraverse.traverse(ast, {
    enter: function(node, parent) {
      if (node.type === 'FunctionDeclaration'
          || node.type === 'FunctionExpression') {
        wrapFunctionBody(node, getBeforeCode(node));
      }
    }
  });
  var prelude =
      "var _ = require('underscore'), describeArgs = " +
      (describeArgs.toString()) + ";";
  return prelude + "\n" + escodegen.generate(ast);
}

function getBeforeCode(node) {
  var name = node.id ? node.id.name : '<anonymous function>';
  var paramNames = _.map(node.params, function(p) {
    return "'" + p.name + "'";
  }).join(', ');
  var describeArgs =
      "describeArgs([" + paramNames + "], arguments)";
  return "console.log('Entering " + name + "(' + " + describeArgs + " + ')');";
}

function wrapFunctionBody(node, beforeCode, afterCode) {
  var beforeNodes = beforeCode != null ? esprima.parse(beforeCode).body : [];
  var afterNodes = afterCode != null ? esprima.parse(afterCode).body : [];
  node.body.body = beforeNodes.concat(node.body.body, afterNodes);
}

function describeArgs(parameterNames, values) {
  var names = _.map(parameterNames, function(name) {
    return "" + name + "=";
  });
  var formatValue = function(v) {
    return _.isString(v) ? "'" + v + "'" : v;
  };
  return _.map(_.zip(names, values), function(each) {
    var _ref;
    return "" + ((_ref = each[0]) != null ? _ref : '') + (formatValue(each[1]));
  }).join(', ');
}

console.log(addLogging("function foo(a, b) {\n    var x = 'blah';\n    var y = (function () {\n        return 3;\n    })();\n}\nfoo(1, 'wut', 3)"));
