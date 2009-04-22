IN: compiler.tree.debugger.tests
USING: compiler.tree.debugger tools.test sorting sequences io math.order ;

[ [ <=> ] sort ] optimized.
[ <reversed> [ print ] each ] optimizer-report.