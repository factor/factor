IN: compiler.tree.debugger.tests
USING: compiler.tree.debugger tools.test sorting sequences io ;

\ optimized. must-infer
\ optimizer-report. must-infer

[ [ <=> ] sort ] optimized.
[ <reversed> [ print ] each ] optimizer-report.