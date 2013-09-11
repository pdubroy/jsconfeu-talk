var _ = require('underscore');
var esprima = require('esprima');
var estraverse = require('estraverse');

function checkStyle(code, filename) {
  var ast = esprima.parse(code, parseOptions);
  var errors = [];
  estraverse.traverse(ast, {
    enter: function(node, parent) {
      if (node.type === 'VariableDeclaration')
        return checkVariableNames(node, errors);
    }
  });
  return formatErrors(code, errors, filename);
}

function checkVariableNames(node, errors) {
  _.each(node.declarations, function(decl) {
    if (decl.id.name.indexOf('_') >= 0) {
      return errors.push({
        location: decl.loc,
        message: 'Use camelCase for variable names, not hacker_style.'
      });
    }
  });
}

// Takes a list of errors found by `checkStyle`, and returns a list of
// human-readable error messages.
function formatErrors(code, errors, filename) {
  return _.map(errors, function(e) {
    var loc = e.location.start;
    var prefix = (typeof filename === "function" ? filename("" + filename + ":" + loc.line + ":" + loc.column) : void 0) ? void 0 : "Line " + loc.line + ", column " + loc.column;
    return "" + prefix + ": " + e.message;
  });
}

var parseOptions = {
  loc: true,
  range: true
};

console.log(checkStyle("var foo = bar;\nvar this_is_bad = 3;\nfunction blah() {\n  return function x() { var oops_another_one; }\n}"));
