USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.build-stack-frame compiler.codegen compiler.units
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.resolve
compiler.cfg.register-allocation compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.verifier compiler.cfg.registers
compiler.cfg.utilities compiler.test cpu.architecture hashtables kernel kernel.private locals math
math.libm namespaces quotations sequences sequences.generalizations tools.test vectors words ;
IN: compiler.cfg.register-allocation.verifier.tests

: init-flow-reps ( -- )
    100 <iota> [ int-rep ] H{ } map>assoc representations set ;

: flow-load ( value -- insn )
    dup 22 + [ ##load-integer new swap >>dst ] dip >>val ;

: flow-use ( value -- insn ) ##replace new swap >>src D: 0 >>loc ;

: flow-copy ( src dst -- insn )
    ##copy new swap >>dst swap >>src int-rep >>rep ;

: flow-spill ( src slot -- insn )
    <spill-slot> ##spill new swap >>dst swap >>src int-rep >>rep ;

: flow-reload ( slot dst -- insn )
    ##reload new swap >>dst swap <spill-slot> >>src int-rep >>rep ;

! Each seed changes registers and slot addresses; the corruption reads a
! different slot, while all operand counts and register assignments remain
! legal. Interval coverage checking alone cannot detect this error.
:: transport-fixture ( seed corrupt? -- cfg snapshot )
    init-flow-reps
    1 flow-load :> definition
    1 flow-use :> use
    definition use 2array insns>cfg :> cfg
    cfg snapshot-value-flow :> snapshot
    seed 3 mod :> reg
    seed 16 * :> slot
    definition reg >>dst drop
    use reg 4 + >>src drop
    definition reg slot flow-spill
    slot corrupt? [ 8 + ] when reg 4 + flow-reload use 4array
    >vector cfg entry>> instructions<<
    cfg snapshot ;

{ t } [ value-flow-verifier-enabled? ] unit-test

{ } [ 32 <iota> [ f transport-fixture check-value-flow ] each ] unit-test

{ } [
    32 <iota> [
        [ t transport-fixture check-value-flow ] curry
        [ bad-allocation-value? ] must-fail-with
    ] each
] unit-test

! Spill bytes are a single address space across representations.
{ { } } [ [let
    H{ } clone :> state
    { 1 } 0 <spill-slot> double-rep state value-flow-write
    { 2 } 4 <spill-slot> int-rep state value-flow-write
    0 <spill-slot> double-rep state value-flow-read
] ] unit-test

:: diamond-fixture ( corrupt? -- cfg snapshot )
    init-flow-reps
    1 flow-load :> first-def
    2 flow-load :> second-def
    first-def second-def ##branch new 3array 0 insns>block :> entry
    { } 1 insns>block :> left
    { } 2 insns>block :> right
    3 flow-use :> use
    ##phi new 3 >>dst
    { { left 1 } { right 2 } } >>inputs :> phi
    phi use 2array 3 insns>block :> join
    left right 2array >vector entry successors<<
    join 1vector left successors<<
    join 1vector right successors<<
    entry block>cfg :> cfg
    cfg snapshot-value-flow :> snapshot
    first-def 0 >>dst drop second-def 1 >>dst drop
    0 2 flow-copy 1vector left instructions<<
    corrupt? [ 0 ] [ 1 ] if 2 flow-copy 1vector right instructions<<
    use 2 >>src 1vector join instructions<<
    cfg snapshot ;

{ } [ f diamond-fixture check-value-flow ] unit-test
[ t diamond-fixture check-value-flow ]
[ bad-allocation-value? ] must-fail-with

! Two simultaneous loop phis exchange values on every back edge. The
! temporary preserves the cycle; the corrupt variant overwrites its source.
:: loop-fixture ( corrupt? -- cfg snapshot )
    init-flow-reps
    1 flow-load :> a
    2 flow-load :> b
    a b 2array 0 insns>block :> entry
    <basic-block> :> body
    <basic-block> :> exit
    3 flow-use :> use-a
    4 flow-use :> use-b
    ##phi new 3 >>dst { { entry 1 } { body 4 } } >>inputs
    ##phi new 4 >>dst { { entry 2 } { body 3 } } >>inputs
    use-a use-b 4array >vector body instructions<<
    body 1vector entry successors<<
    body exit 2array >vector body successors<<
    entry block>cfg :> cfg
    cfg snapshot-value-flow :> snapshot
    a 0 >>dst drop b 1 >>dst drop
    use-a 0 >>src use-b 1 >>src 2array >vector body instructions<<
    0 2 flow-copy 1 0 flow-copy
    corrupt? [ 0 ] [ 2 ] if 1 flow-copy 3array 4 insns>block :> back
    body 1vector back successors<<
    back exit 2array >vector body successors<<
    cfg cfg-changed cfg predecessors-changed
    cfg snapshot ;

{ } [ f loop-fixture check-value-flow ] unit-test
[ t loop-fixture check-value-flow ]
[ bad-allocation-value? ] must-fail-with

! Generated parallel permutations are lowered by the real resolver. Rotations
! include single cycles and disjoint cycles, using its temporary spill slot.
! The expected values come from the original SSA uses, not resolver mappings.
:: permutation-fixture ( size rotation corrupt? -- cfg snapshot )
    init-flow-reps
    size <iota> [ 1 + flow-load ] map :> definitions
    size <iota> [ 1 + flow-use ] map :> uses
    definitions uses append insns>cfg :> graph
    graph snapshot-value-flow :> snapshot
    definitions [ >>dst drop ] each-index
    uses [ rotation + size mod >>src drop ] each-index
    graph cfg [
        init-resolve
        size <iota> [| index |
            index int-rep <location>
            index rotation + size mod int-rep <location> 2array
        ] map mapping-instructions
    ] with-variable :> moves
    corrupt? [ moves rest ] [ moves ] if :> final-moves
    definitions final-moves append uses append >vector
    graph entry>> instructions<<
    graph snapshot ;

{ } [
    6 <iota> [ 2 + ] map [| size |
        size 1 - <iota> [ 1 + ] map [| rotation |
            size rotation f permutation-fixture check-value-flow
            [ size rotation t permutation-fixture check-value-flow ]
            [ bad-allocation-value? ] must-fail-with
        ] each
    ] each
] unit-test

! ABI inputs and outputs are physical spill locations at the clobber.
:: abi-fixture ( corrupt? -- cfg snapshot )
    init-flow-reps
    1 flow-load :> a
    ##alien-assembly new { { 1 0 int-rep } } >>reg-inputs
    { } >>stack-inputs { { 2 0 int-rep } } >>reg-outputs :> call
    2 flow-use :> use
    a call use 3array insns>cfg :> cfg
    cfg snapshot-value-flow :> snapshot
    a 0 >>dst drop
    { { T{ spill-slot { n 0 } } 0 int-rep } } call reg-inputs<<
    { { T{ spill-slot { n 8 } } 0 int-rep } } call reg-outputs<<
    use 1 >>src drop
    a 0 corrupt? [ 16 ] [ 0 ] if flow-spill call
    8 1 flow-reload use 5 narray >vector cfg entry>> instructions<<
    cfg snapshot ;

{ } [ f abi-fixture check-value-flow ] unit-test
[ t abi-fixture check-value-flow ]
[ bad-allocation-value? ] must-fail-with

! A call destroys the stale register copy even though the input has been
! spilled correctly and the following use still has a legal register.
[ [let
    f abi-fixture :> ( cfg snapshot )
    cfg entry>> instructions>> last 0 >>src drop
    cfg snapshot check-value-flow
] ] [ bad-allocation-value? ] must-fail-with

[ [let
    0 f transport-fixture :> ( cfg snapshot )
    cfg entry>> instructions>> pop*
    cfg snapshot check-value-flow
] ] [ lost-allocation-instruction? ] must-fail-with

:: gc-fixture ( -- cfg snapshot )
    init-flow-reps tagged-rep 1 set-rep-of
    ##load-reference new 1 >>dst { 1 2 3 } >>obj :> definition
    ##call-gc new <gc-map> >>gc-map :> gc
    1 flow-use :> use
    definition gc use 3array insns>cfg :> cfg
    cfg snapshot-value-flow :> snapshot
    definition 0 >>dst drop use 0 >>src drop
    0 <spill-slot> 1array gc gc-map>> gc-roots<<
    definition 0 0 flow-spill tagged-rep >>rep gc
    0 0 flow-reload tagged-rep >>rep use 5 narray >vector
    cfg entry>> instructions<<
    cfg snapshot ;

{ } [ gc-fixture check-value-flow ] unit-test

[ [let
    gc-fixture :> ( cfg snapshot )
    cfg entry>> [ [ ##spill? ] reject ] change-instructions drop
    cfg snapshot check-value-flow
] ] [ invalid-allocation-gc-root? ] must-fail-with

[ [let
    gc-fixture :> ( cfg snapshot )
    cfg entry>> [ [ ##reload? ] reject ] change-instructions drop
    cfg snapshot check-value-flow
] ] [ bad-allocation-value? ] must-fail-with

[ [let
    gc-fixture :> ( cfg snapshot )
    cfg entry>> instructions>> [ ##call-gc? ] find nip gc-map>>
    { { T{ spill-slot { n 0 } } T{ spill-slot { n 0 } } } }
    >>derived-roots drop
    cfg snapshot check-value-flow
] ] [ overlapping-allocation-gc-roots? ] must-fail-with

! An additional uninitialized root is unsafe even when every required root
! remains present in the map.
[ [let
    gc-fixture :> ( cfg snapshot )
    cfg entry>> instructions>> [ ##call-gc? ] find nip gc-map>>
    [ 16 <spill-slot> suffix ] change-gc-roots drop
    cfg snapshot check-value-flow
] ] [ invalid-allocation-gc-root? ] must-fail-with

! A second, unrooted spill is stale after collection. Rooting another copy
! of the same value does not update this slot.
[ [let
    gc-fixture :> ( cfg snapshot )
    cfg entry>> [
        0 8 flow-spill tagged-rep >>rep 2 rot insert-nth
    ] change-instructions drop
    cfg entry>> instructions>> [ ##reload? ] find nip
    8 <spill-slot> >>src drop
    cfg snapshot check-value-flow
] ] [ bad-allocation-value? ] must-fail-with

:: derived-map-fixture ( -- cfg snapshot gc )
    init-flow-reps tagged-rep 0 set-rep-of tagged-rep 3 set-rep-of
    ##load-reference new 0 >>dst { 1 } >>obj :> base
    ##load-reference new 3 >>dst { 2 } >>obj :> other
    ##tagged>integer new 1 >>dst 0 >>src :> cast
    ##add-imm new 2 >>dst 1 >>src1 16 >>src2 :> derived
    ##call-gc new <gc-map> >>gc-map :> gc
    2 flow-use :> use
    { base other cast derived gc use } insns>cfg :> cfg
    cfg snapshot-value-flow :> snapshot
    other 2 >>dst drop derived 1 >>dst 0 >>src1 drop use 1 >>src drop
    { T{ spill-slot { n 0 } } T{ spill-slot { n 16 } } } gc gc-map>> gc-roots<<
    { { T{ spill-slot { n 8 } } T{ spill-slot { n 0 } } } } gc gc-map>> derived-roots<<
    base other derived
    0 0 flow-spill tagged-rep >>rep
    2 16 flow-spill tagged-rep >>rep
    1 8 flow-spill gc 8 1 flow-reload use 9 narray >vector
    cfg entry>> instructions<<
    cfg snapshot gc ;

{ } [ derived-map-fixture drop check-value-flow ] unit-test

[ derived-map-fixture gc-map>> { } >>derived-roots drop check-value-flow ]
[ invalid-allocation-derived-root? ] must-fail-with

[ derived-map-fixture gc-map>>
    { { T{ spill-slot { n 8 } } T{ spill-slot { n 16 } } } }
    >>derived-roots drop check-value-flow
] [ invalid-allocation-derived-root? ] must-fail-with

:: vector-transport-fixture ( narrow? -- cfg snapshot )
    init-flow-reps double-2-rep 1 set-rep-of
    ##load-vector new 1 >>dst double-2-rep >>rep :> definition
    1 flow-use :> use
    definition use 2array insns>cfg :> cfg
    cfg snapshot-value-flow :> snapshot
    definition 0 >>dst drop use 1 >>src drop
    definition 0 0 flow-spill double-2-rep >>rep
    0 1 flow-reload narrow? [ double-rep ] [ double-2-rep ] if >>rep
    use 4array >vector cfg entry>> instructions<<
    cfg snapshot ;

{ } [ f vector-transport-fixture check-value-flow ] unit-test
[ t vector-transport-fixture check-value-flow ]
[ bad-allocation-value? ] must-fail-with

[ [let
    init-flow-reps
    1 flow-load :> definition
    ##dispatch new 1 >>src 2 >>temp :> use
    definition use 2array insns>cfg :> cfg
    cfg snapshot-value-flow :> snapshot
    definition 0 >>dst drop use 0 >>src 0 >>temp drop
    cfg snapshot check-value-flow
] ] [ invalid-allocation-temporary? ] must-fail-with

:: rematerialization-fixture ( literal -- cfg snapshot )
    init-flow-reps
    1 flow-load :> definition
    1 flow-use :> use-a
    1 flow-use :> use-b
    definition use-a use-b 3array insns>cfg :> cfg
    cfg snapshot-value-flow :> snapshot
    definition 0 >>dst drop use-a 0 >>src drop use-b 1 >>src drop
    1 flow-load literal >>val :> remat
    snapshot active-value-flow-snapshot [
        definition remat record-value-flow-rematerialization
    ] with-variable
    definition remat use-a use-b 4array >vector cfg entry>> instructions<<
    cfg snapshot ;

! Rematerializing a constant must preserve a simultaneous resident copy.
{ } [ 23 rematerialization-fixture check-value-flow ] unit-test
[ 24 rematerialization-fixture check-value-flow ]
[ invalid-allocation-rematerialization? ] must-fail-with

! Corruption after the provenance notification is checked again at the use
! of the final generated instruction, against an immutable recipe literal.
[ [let
    23 rematerialization-fixture :> ( cfg snapshot )
    cfg entry>> instructions>> second 99 >>val drop
    cfg snapshot check-value-flow
] ] [ invalid-allocation-rematerialization? ] must-fail-with

CONSTANT: flow-allocators {
    linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator
}

! A deleted tagged>integer must not hide a heap pointer from the collector.
! The original input remains rooted on the caller's stack; pointer identity
! after the explicit collection detects an unrelocated register spill.
:: compile-moving-root ( allocator -- word )
    H{ { 0 tagged-rep } { 1 int-rep } { 2 int-rep } { 3 int-rep } }
    clone representations set
    4 vreg-counter set
    {
        T{ ##prologue }
        T{ ##peek { dst 0 } { loc D: 0 } }
        T{ ##tagged>integer { dst 1 } { src 0 } }
        T{ ##save-context { temp1 2 } { temp2 3 } }
        T{ ##call-gc { gc-map T{ gc-map } } }
        T{ ##replace { src 1 } { loc D: 0 } }
        T{ ##epilogue }
        T{ ##return }
    } [ clone ] map insns>cfg :> graph
    graph cfg set
    allocator register-allocator set
    graph allocate-registers
    graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;

:: compile-moving-offset ( allocator -- word )
    H{ { 0 tagged-rep } { 1 int-rep } { 2 int-rep }
       { 3 int-rep } { 4 int-rep } { 5 int-rep } }
    clone representations set
    6 vreg-counter set
    {
        T{ ##prologue }
        T{ ##peek { dst 0 } { loc D: 0 } }
        T{ ##tagged>integer { dst 1 } { src 0 } }
        T{ ##add-imm { dst 2 } { src1 1 } { src2 16 } }
        T{ ##save-context { temp1 3 } { temp2 4 } }
        T{ ##call-gc { gc-map T{ gc-map } } }
        T{ ##sub-imm { dst 5 } { src1 2 } { src2 16 } }
        T{ ##replace { src 5 } { loc D: 0 } }
        T{ ##epilogue }
        T{ ##return }
    } [ clone ] map insns>cfg :> graph
    graph cfg set
    allocator register-allocator set
    graph allocate-registers
    graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;

{ t } [
    t check-allocation? [
        flow-allocators [| allocator |
            [
                allocator compile-moving-root :> word
                20 <iota> [
                    1array dup word execute( x -- x ) eq?
                ] all?
                ! A nonzero offset needs a distinct derived slot and its
                ! own relocation, even with coalescing opportunities.
                allocator compile-moving-offset :> offset-word
                20 <iota> [
                    1array dup offset-word execute( x -- x ) eq?
                ] all? and
            ] with-scope
        ] all?
    ] with-variable
] unit-test

:: generated-flow-program ( seed -- quot )
    seed 5 mod 1 + :> count
    '[ { fixnum } declare seed + dup odd?
        [ 3 * ] [ 2 - ] if count [ 1 + ] times ] ;

:: generated-flow-result ( input seed -- result )
    input seed + dup odd? [ 3 * ] [ 2 - ] if seed 5 mod 1 + + ;

! Deterministic generated programs exercise a join and a counted loop for
! both branch outcomes, and compare executed code against a separate scalar
! oracle under every allocator. These finite tests are not a proof.
{ } [
    t check-allocation? [
        flow-allocators [| allocator |
            allocator register-allocator [
                8 <iota> [| seed |
                    { -7 0 8 } [| input |
                        input seed generated-flow-program compile-call
                        input seed generated-flow-result assert=
                    ] each
                ] each
                1.0 [ 4 [ fsin ] times ] compile-call
                1.0 4 [ fsin ] times assert=
                [ 1 2 5 [ swap ] times 2array ] compile-call { 2 1 } assert=
            ] with-variable
        ] each
    ] with-variable
] unit-test
