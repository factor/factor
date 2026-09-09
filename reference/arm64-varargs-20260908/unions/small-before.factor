USING: assocs combinators compiler.errors cpu.architecture cpu.arm.64.abi debugger io kernel namespaces parser sequences system tools.test ;
IN: cpu.arm.64.abi
: homogeneous-rep ( rep -- rep' )
    {
        { [ dup small-float-rep? ] [ drop small-float-rep ] }
        { [ dup vector-rep? ] [ drop float-4-rep ] }
        [ ]
    } cond ;
IN: small-union-check
f restartable-tests? set-global
"resource:basis/compiler/tests/alien-arm64-unions.factor" run-test-file
"resource:basis/compiler/tests/alien-small-floats.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
