USING: assocs compiler.errors io.files io.pathnames kernel math namespaces
parser prettyprint sequences system tools.test vocabs.loader ;
"resource:" absolute-path .
"resource:reference/arm64-gap-reduced-ffi-20260908/refresh.factor" run-file
"resource:basis/compiler/tests/alien-small-floats.factor" run-test-file
"math.floats.small" test
"cpu.arm.64.assembler" test
"resource:basis/compiler/tests/alien.factor" run-test-file
"compiler.cfg.builder.alien" test
"test failures" . test-failures get length dup .
"compiler errors" . compiler-errors get assoc-size dup .
+ 0 = 0 1 ? exit
