USING: alien byte-arrays compiler.cfg.instructions compiler.test
cpu.architecture kernel kernel.private math math.vectors.simd.intrinsics
sequences tools.test ;
IN: compiler.tree.propagation.simd.tests

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
