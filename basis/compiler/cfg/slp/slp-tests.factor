USING: accessors arrays assocs compiler.cfg.instructions compiler.cfg.registers
compiler.cfg compiler.cfg.utilities compiler.cfg.def-use compiler.cfg.slp combinators kernel locals math namespaces sequences tools.test vectors ;
IN: compiler.cfg.slp.tests

:: scalar-chain ( first-id input scale bias rounds -- insns last )
    V{ } clone :> insns
    input :> previous!
    rounds [| i |
        first-id i 2 * + :> product
        product 1 + :> sum
        product previous scale ##xor new-insn insns push
        sum product bias ##add new-insn insns push
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

! Two ordinary twelve-step integer recurrences save twenty-four arithmetic ops,
! enough to pay for three gathers and both scalar outputs. Operator order
! remains twenty-four alternating xor/add instructions, without reassociation.
{ 12 12 3 2 0 0 } [
    12 scalar-pair pack-test
    { [ [ ##xor-vector? ] count ]
    [ [ ##add-vector? ] count ]
    [ [ ##gather-int-vector-2? ] count ]
    [ [ ##select-vector? ] count ]
    [ [ ##shuffle-vector-imm? ] count ]
    [ [ slp-arithmetic? ] count ] } cleave
] unit-test

! Packing overhead dominates a short pair, which must remain scalar.
{ t } [ 2 scalar-pair dup pack-test = ] unit-test

! A side effect splits the scheduling region. Never move arithmetic across
! calls, stores, or GC; the same conservative boundary covers ABI changes.
{ t } [
    12 scalar-pair 24 cut
    [ T{ ##call } suffix ] dip append dup pack-test =
] unit-test

! A first result consumed before the second chain must not move past its use.
{ t } [
    12 scalar-pair 24 cut
    [ 33 D: 2 ##replace new-insn suffix ] dip append dup pack-test =
] unit-test

! FP remains scalar even when packing would be profitable. The first enabled
! FP trap and its accrued flags can depend on scalar evaluation order.
{ t } [
    12 scalar-pair [
        dup ##xor? [ [ dst>> ] [ src1>> ] [ src2>> ] tri ##mul-float new-insn ] when
        dup ##add? [ [ dst>> ] [ src1>> ] [ src2>> ] tri ##add-float new-insn ] when
    ] map dup pack-test =
] unit-test

! Overflow-checking arithmetic carries branches and must remain scalar.
{ t } [
    12 scalar-pair [
        dup ##add? [ [ dst>> ] [ src1>> ] [ src2>> ] tri f ##fixnum-add new-insn ] when
    ] map dup pack-test =
] unit-test

! Shared intermediate values retain their original scalar definition, even
! when the remaining suffix is profitable to pack.
{ t } [
    12 scalar-pair 11 D: 2 ##replace new-insn suffix pack-test
    [ defs-vregs 11 swap member? ] any?
] unit-test

! Raw pointers may cross GC after the region. A vector extraction would
! hide the scalar add/sub base chain, so either provenance seed anywhere
! in the CFG disables packing, including otherwise profitable numeric code.
{ { { 0 1 } { 0 1 } } } [
    { T{ ##tagged>integer { dst 200 } { src 201 } }
      T{ ##unbox-any-c-ptr { dst 200 } { src 201 } } } [| seed |
        12 scalar-pair seed prefix T{ ##call-gc } suffix insns>cfg :> graph
        t automatic-slp? [
            graph auto-vectorize
            "packs" slp-statistics get at
            "pointer-cfgs-skipped" slp-statistics get at 2array
        ] with-variable
    ] map
] unit-test
