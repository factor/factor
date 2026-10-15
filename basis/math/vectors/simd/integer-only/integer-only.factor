! Focused capability controls use opaque payloads so the tests themselves
! require no floating arithmetic before choosing the executing VM's branch.
USING: accessors byte-arrays compiler.cfg
compiler.cfg.instructions compiler.cfg.intrinsics.simd
compiler.tree compiler.tree.propagation.info cpu.architecture kernel locals math
math.vectors.simd.intrinsics math.vectors.simd.intrinsics.private words ;
IN: math.vectors.simd.integer-only

:: representation-node ( rep -- node )
    T{ #call
        { in-d { 1 2 3 4 } } { out-d { 5 } }
        { info H{
            { 1 T{ value-info-state { class byte-array } } }
            { 2 T{ value-info-state { class byte-array } } }
            { 3 T{ value-info-state { class byte-array } } }
            { 4 T{ value-info-state { class word } { literal? t } { literal rep } } }
            { 5 T{ value-info-state { class byte-array } } }
        } }
    } ;

: opaque-one-reference ( -- insn )
    T{ ##load-reference { dst 0 } } clone
    0x3ff0000000000000 bits>double >>obj ;
