USING: accessors arrays assocs compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.def-use compiler.cfg.slp combinators kernel locals math namespaces sequences tools.test vectors ;
IN: compiler.cfg.slp.tests

:: scalar-chain ( first-id input scale bias rounds -- insns last )
    V{ } clone :> insns
    input :> previous!
    rounds [| i |
        first-id i 2 * + :> product
        product 1 + :> sum
        product previous scale ##mul-float new-insn insns push
        sum product bias ##add-float new-insn insns push
        sum previous!
    ] each-integer
    insns previous ;

:: scalar-pair ( rounds -- insns )
    10 0 2 3 rounds scalar-chain :> ( left a )
    50 1 2 3 rounds scalar-chain :> ( right b )
    left right append
    a D: 0 ##replace new-insn suffix
    b D: 1 ##replace new-insn suffix ;

:: pack-test ( insns -- insns' )
    1000 vreg-counter namespaces:set
    H{ { "packs" 0 } { "vector-operations" 0 } } clone slp-statistics namespaces:set
    H{ } clone :> uses
    insns [ uses-vregs [ uses inc-at ] each ] each
    insns uses vectorize-slp-block ;

! Two ordinary seven-step affine recurrences save fourteen arithmetic ops,
! enough to pay for three gathers and both scalar outputs. Operator order
! remains fourteen alternating multiply/add instructions, without FMA.
{ 7 7 3 2 1 0 } [
    7 scalar-pair pack-test
    { [ [ ##mul-vector? ] count ]
    [ [ ##add-vector? ] count ]
    [ [ ##gather-vector-2? ] count ]
    [ [ ##vector>scalar? ] count ]
    [ [ ##shuffle-vector-imm? ] count ]
    [ [ slp-arithmetic? ] count ] } cleave
] unit-test

! Packing overhead dominates a short pair, which must remain scalar.
{ t } [ 2 scalar-pair dup pack-test = ] unit-test

! A side effect splits the scheduling region. Never move arithmetic across
! calls, stores, or GC; the same conservative boundary covers ABI changes.
{ t } [
    7 scalar-pair 14 cut
    [ T{ ##call } suffix ] dip append dup pack-test =
] unit-test

! A first result consumed before the second chain must not move past its use.
{ t } [
    7 scalar-pair 14 cut
    [ 23 D: 2 ##replace new-insn suffix ] dip append dup pack-test =
] unit-test
