USING: compiler.tree.debugger tools.test sorting sequences io math.order ;
IN: compiler.tree.debugger.tests

[ [ <=> ] sort-with ] optimized.
[ <reversed> write-lines ] optimizer-report.
