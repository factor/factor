USING: vocabs.loader tools.test namespaces sequences system ;
"compiler.tree.propagation.info" require
"compiler.tree.propagation.info" test
"classes.algebra" require "classes.algebra" test
:test-failures test-failures get empty? [ 0 ] [ 1 ] if exit
