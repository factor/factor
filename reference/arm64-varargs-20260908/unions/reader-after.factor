USING: accessors alien.c-types alien.varargs alien.varargs.private cpu.arm.64 cpu.arm.64.abi assocs classes.struct compiler.errors debugger io kernel locals namespaces parser sequences system tools.test ;
IN: cpu.arm.64
: homogeneous-float/vector-aggregate? ( c-type -- reps ? )
    lookup-c-type homogeneous-aggregate-members
    [ [ third ] map t ] [ { } f ] if* ;
IN: alien.varargs.private
:: <va-layout> ( type -- layout )
    type lookup-c-type :> resolved
    resolved homogeneous-aggregate-members :> members
    va-layout new
        type heap-size >>size type c-type-align >>alignment
        members [ ] [ { } ] if* >>members resolved struct-c-type? >>aggregate?
        members >boolean >>homogeneous? ;
IN: arm64-union-test-driver
f restartable-tests? set-global
"resource:basis/compiler/tests/alien-arm64-unions.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
