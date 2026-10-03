USING: accessors alien.c-types arrays classes.struct
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params cpu.architecture cpu.riscv.64.abi
kernel literals namespaces sequences system tools.test vectors ;
IN: cpu.riscv.64.abi.tests

STRUCT: padded-floats { a float } { b double } ;
STRUCT: mixed-fields { a char } { b double } ;
STRUCT: nested-fields { a padded-floats } ;
STRUCT: array-fields { a float[2] } ;
STRUCT: three-floats { a float[3] } ;
PACKED-STRUCT: packed-fields { a char } { b double } ;
UNION-STRUCT: float-union { a float } ;
STRUCT: union-field { a float-union } { b float } ;
STRUCT: bit-and-float { a uint bits: 3 } { b double } ;
PACKED-STRUCT: float-and-bit { a float } { b int bits: 13 } ;
STRUCT: two-bits-and-float { a uint bits: 3 } { b uint bits: 5 } { c double } ;
STRUCT: zero-bit-and-float { a uint bits: 0 } { b float } ;

{ { 0 8 } } [ padded-floats lookup-c-type fp-struct-members [ first ] map ] unit-test
! Return classification also receives unresolved struct class words.
{ { 0 8 } } [ padded-floats fp-struct-members [ first ] map ] unit-test
{ { int-rep double-rep } } [ bit-and-float fp-struct-members [ third ] map ] unit-test
{ { 0 8 } } [ mixed-fields lookup-c-type fp-struct-members [ first ] map ] unit-test
{ { 1 8 } } [ mixed-fields lookup-c-type fp-struct-members [ second ] map ] unit-test
{ { float-rep double-rep } } [ padded-floats lookup-c-type fp-struct-members [ third ] map ] unit-test
{ { int-rep double-rep } } [ mixed-fields lookup-c-type fp-struct-members [ third ] map ] unit-test
{ { 0 8 } } [ nested-fields lookup-c-type fp-struct-members [ first ] map ] unit-test
{ { 0 4 } } [ array-fields lookup-c-type fp-struct-members [ first ] map ] unit-test
{ { 0 1 } } [ packed-fields lookup-c-type fp-struct-members [ first ] map ] unit-test
{ f } [ three-floats lookup-c-type fp-struct-members ] unit-test
{ f } [ float-union lookup-c-type fp-struct-members ] unit-test
{ f } [ union-field lookup-c-type fp-struct-members ] unit-test
{ { 0 8 } } [ bit-and-float lookup-c-type fp-struct-members [ first ] map ] unit-test
{ { int-rep double-rep } } [ bit-and-float lookup-c-type fp-struct-members [ third ] map ] unit-test
{ { 0 4 } } [ float-and-bit lookup-c-type fp-struct-members [ first ] map ] unit-test
{ { float-rep int-rep } } [ float-and-bit lookup-c-type fp-struct-members [ third ] map ] unit-test
{ f } [ two-bits-and-float lookup-c-type fp-struct-members ] unit-test
{ { float-rep } } [ zero-bit-and-float lookup-c-type fp-struct-members [ third ] map ] unit-test

{ t } [
    7 int-reg-reps [ 7 float-reg-reps [
        mixed-fields lookup-c-type parameter-fp-members >boolean
    ] with-variable ] with-variable
] unit-test
! Spilled integer arguments do not consume the independent FP bank.
{ t } [
    16 int-reg-reps [ 0 float-reg-reps [
        padded-floats lookup-c-type parameter-fp-members >boolean
    ] with-variable ] with-variable
] unit-test
{ f } [
    8 int-reg-reps [ 0 float-reg-reps [
        mixed-fields lookup-c-type parameter-fp-members
    ] with-variable ] with-variable
] unit-test
{ f } [
    0 int-reg-reps [ 7 float-reg-reps [
        padded-floats lookup-c-type parameter-fp-members
    ] with-variable ] with-variable
] unit-test
{ f } [
    t varargs-parameter? [ mixed-fields lookup-c-type parameter-fp-members ] with-variable
] unit-test
{ t } [
    8 float-reg-reps [ double lookup-c-type scalar-integer-convention? ] with-variable
] unit-test
{ t } [
    t varargs-parameter? [ float lookup-c-type scalar-integer-convention? ] with-variable
] unit-test
{ f } [
    7 float-reg-reps [ double lookup-c-type scalar-integer-convention? ] with-variable
] unit-test

! A named two-cell aggregate may split between a7 and the stack. Align its
! stack portion without discarding the remaining register.
{ 16 1 } [
    V{ 1 } clone int-regs [ 8 stack-params [
        { { int-rep f f } { int-rep f f } } 16 mark-integer-struct-reps first
        M\ riscv.64 prepare-abi-parameter-group execute
        stack-params get int-regs get length
    ] with-variable ] with-variable
] unit-test
{ 8 2 } [
    V{ 2 1 } clone int-regs [ 8 stack-params [
        { { int-rep f f } { int-rep f f } } 16 mark-integer-struct-reps first
        M\ riscv.64 prepare-abi-parameter-group execute
        stack-params get int-regs get length
    ] with-variable ] with-variable
] unit-test
