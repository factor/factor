USING: alien byte-arrays compiler.cfg.instructions compiler.test
cpu.architecture kernel kernel.private math math.vectors math.vectors.simd math.vectors.simd.intrinsics
sequences tools.test ;
IN: compiler.tree.propagation.simd.tests

! Dot products accumulate without narrowing; even int-4 products can exceed
! an x86-64 fixnum. Incorrect output information can fold bignum? to false.
{ V{ integer } } [ [ { int-4 int-4 } declare vdot ] final-classes ] unit-test
{ V{ integer } } [ [ { uint-4 uint-4 } declare vdot ] final-classes ] unit-test
{ V{ float } } [ [ { float-4 float-4 } declare vdot ] final-classes ] unit-test
{ V{ float } } [ [ { half-8 half-8 } declare vdot ] final-classes ] unit-test

{ t } [
    int-4{ 2147483647 2147483647 2147483647 2147483647 } dup
    [ { int-4 int-4 } declare vdot bignum? ] compile-call
] unit-test

{ t } [
    uint-4{ 4294967295 4294967295 4294967295 4294967295 } dup
    [ { uint-4 uint-4 } declare vdot bignum? ] compile-call
] unit-test

! Correct results alone do not detect an allocating scalar fallback here.
! The dummy CFG probe must accept block-aware memory intrinsic effects.
float-4-rep %alien-vector-reps member? [
    { t } [
        [ { c-ptr fixnum } declare float-4-rep alien-vector ]
        [ [ ##load-memory? ] [ ##load-memory-imm? ] bi or ] contains-insn?
    ] unit-test
    { t } [
        [ { byte-array c-ptr fixnum } declare float-4-rep set-alien-vector ]
        [ [ ##store-memory? ] [ ##store-memory-imm? ] bi or ] contains-insn?
    ] unit-test
] when
