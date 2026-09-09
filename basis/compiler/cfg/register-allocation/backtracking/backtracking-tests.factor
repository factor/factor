USING: accessors arrays assocs combinators compiler.test compiler.cfg compiler.cfg.metrics
compiler.cfg.register-allocation compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.verifier compiler.cfg.register-allocation.validation
compiler.cfg.ssa.destruction.leaders compiler.cfg.instructions
compiler.cfg.checker compiler.cfg.liveness compiler.cfg.linear-scan.numbering compiler.cfg.linearization compiler.cfg.utilities
compiler.cfg.register-allocation.ssa compiler.cfg.register-allocation.ssa.phases
compiler.cfg.linear-scan.assignment compiler.cfg.register-allocation.occupancy
compiler.cfg.register-allocation.spill-sites
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.registers
cpu.architecture layouts generalizations kernel kernel.private locals make math math.order quotations math.private namespaces sequences tools.test
vectors memory continuations hashtables io.sockets io.sockets.private words ;
IN: compiler.cfg.register-allocation.backtracking.tests

:: test-interval ( vreg positions -- interval )
    vreg <live-interval>
    positions first positions last 2array 1vector >>ranges
    positions [ <vreg-use> int-rep >>use-rep ] map >vector >>uses ;

: init-test-allocation ( -- registers )
    f backtracking-phase-mode? set
    f backtracking-point-blocks set
    f f <basic-block> <cfg> cfg set
    H{ { 1 int-rep } { 2 int-rep } } representations set
    int-regs machine-registers int-regs of first 1array 2array 1array ;

! A long sparse interval is processed first. A short dense interval must
! revoke its assignment, then the sparse interval must split and retry.
{ t t t } [
    init-test-allocation [
        1 { 0 100 } test-interval
        2 { 20 22 24 40 } test-interval 2array
        swap backtracking-allocation
    ] keep [ check-allocated-intervals ] 2keep drop
    [ spill-to>> ] any?
    backtracking-evictions get 0 >
    backtracking-splits get 0 >
] unit-test

! Same-value fragments form one bundle and share a physical register.
{ 1 t } [
    init-test-allocation
    1 { 0 10 } test-interval
    1 { 20 30 } test-interval 2array swap backtracking-allocation
    assigned-bundles get length swap [ reg>> ] map first2 =
] unit-test

! Mandatory clobber splitting preserves both the incoming spill and the
! outgoing reload, while dropping the call's memory-only operand.
{ 2 t t } [
    init-test-allocation
    1 { 0 40 100 } test-interval
    T{ sync-point { n 40 } } 2array swap backtracking-allocation
    [ length ] [ [ spill-to>> ] any? ] [ [ reload-from>> ] any? ] tri
] unit-test

{ 42 } [
    backtracking-allocator register-allocator [
        19 23 [ { fixnum fixnum } declare + ] compile-call
    ] with-variable
] unit-test

{ 7.5 } [
    backtracking-allocator register-allocator [
        1.5 2.0 3.0 [ * + ] compile-call
    ] with-variable
] unit-test

{ { 1 2 3 } } [
    backtracking-allocator register-allocator [
        { 1 2 3 } [ dup gc drop ] compile-call
    ] with-variable
] unit-test

{ 4950 } [
    backtracking-allocator register-allocator [
        100 [ <iota> 0 [ + ] reduce ] compile-call
    ] with-variable
] unit-test

! Fresh CFGs go through the common comparison harness.
{ t } [
    [ { fixnum fixnum } declare + ]
    { linear-scan-allocator backtracking-allocator } compare-allocators
    [ "procedures" of first "code-bytes" of 0 > ] all?
] unit-test

! Forty distinct values remain live before their reduction, exceeding the
! native integer register file. This exercises emitted spills and reloads.
: pressure-quotation ( -- quot )
    [
        {
            [ 1 fixnum+fast ]
            [ 2 fixnum+fast ]
            [ 3 fixnum+fast ]
            [ 4 fixnum+fast ]
            [ 5 fixnum+fast ]
            [ 6 fixnum+fast ]
            [ 7 fixnum+fast ]
            [ 8 fixnum+fast ]
            [ 9 fixnum+fast ]
            [ 10 fixnum+fast ]
            [ 11 fixnum+fast ]
            [ 12 fixnum+fast ]
            [ 13 fixnum+fast ]
            [ 14 fixnum+fast ]
            [ 15 fixnum+fast ]
            [ 16 fixnum+fast ]
            [ 17 fixnum+fast ]
            [ 18 fixnum+fast ]
            [ 19 fixnum+fast ]
            [ 20 fixnum+fast ]
            [ 21 fixnum+fast ]
            [ 22 fixnum+fast ]
            [ 23 fixnum+fast ]
            [ 24 fixnum+fast ]
            [ 25 fixnum+fast ]
            [ 26 fixnum+fast ]
            [ 27 fixnum+fast ]
            [ 28 fixnum+fast ]
            [ 29 fixnum+fast ]
            [ 30 fixnum+fast ]
            [ 31 fixnum+fast ]
            [ 32 fixnum+fast ]
            [ 33 fixnum+fast ]
            [ 34 fixnum+fast ]
            [ 35 fixnum+fast ]
            [ 36 fixnum+fast ]
            [ 37 fixnum+fast ]
            [ 38 fixnum+fast ]
            [ 39 fixnum+fast ]
            [ 40 fixnum+fast ]
        } cleave
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
    ] ;

{ 1220 } [
    backtracking-allocator register-allocator [
        10 pressure-quotation compile-call
    ] with-variable
] unit-test

{ t t } [
    pressure-quotation { linear-scan-allocator backtracking-allocator }
    compare-allocators [
        [ "procedures" of [ "passes" of last "spills" of ] map-sum 0 > ] all?
    ] [
        second "procedures" of first "allocation" of "evictions" of 0 >
    ] bi
] unit-test

! An atomic memory-only clobber operand still needs a stack slot, although
! it has no surviving register interval on either side of the instruction.
{ t 1 } [
    init-test-allocation
    1 { 40 } test-interval dup uses>> first t >>spill-slot? drop
    T{ sync-point { n 40 } } 2array swap backtracking-allocation empty?
    spill-slots get assoc-size
] unit-test

! Compare indexed queries with the original pairwise oracle after real
! evictions and spills have removed/replaced ranges in the occupancy index.
{ t } [
    init-test-allocation
    1 { 0 100 } test-interval
    2 { 20 22 24 40 } test-interval 2array swap backtracking-allocation drop
    assigned-bundles get [| bundle |
        bundle intervals>> first reg>> :> reg
        bundle reg bundle-conflicts
        assigned-bundles get [| other |
            other intervals>> first reg>> reg =
            other bundle-reg-class bundle bundle-reg-class = and
            other bundle bundles-intersect? and
        ] filter >array =
    ] all?
] unit-test

! Different SSA values can share one allocation bundle without becoming
! leader aliases. The edge affinity requires equal locations, not equal bits.
{ 1 1 t t } [ [
    { { 1 2 } } backtracking-affinities set
    init-test-allocation
    1 { 0 10 } test-interval
    2 { 20 30 } test-interval 2array swap backtracking-allocation
    assigned-bundles get length
    backtracking-merges get
    rot [ reg>> ] map first2 =
    1 bundle-spillsets get at 2 bundle-spillsets get at eq?
] with-scope ] unit-test

! Interfering values must not merge even if a copy/phi requested affinity.
{ 0 } [ [
    { { 1 2 } } backtracking-affinities set
    init-test-allocation
    1 { 0 20 } test-interval
    2 { 10 30 } test-interval 2array swap backtracking-allocation drop
    backtracking-merges get
] with-scope ] unit-test

! Distinct spillsets may reuse storage only when their complete original
! live ranges do not intersect. Their SSA identities stay distinct.
{ t 1 1 } [ [
    f backtracking-affinities set
    init-test-allocation
    1 { 0 10 } test-interval
    2 { 20 30 } test-interval 2array swap backtracking-allocation drop
    1 bundle-spillsets get at ensure-spillset-home
    2 bundle-spillsets get at ensure-spillset-home
    1 int-rep lookup-spill-slot 2 int-rep lookup-spill-slot =
    spill-home-pool get length backtracking-shared-homes get
] with-scope ] unit-test

! A conflict at 12 selects the preceding legal gap, not the median use.
{ 9 } [ [
    init-test-allocation drop
    1 { 0 10 20 30 100 } test-interval 1array <allocation-bundle>
    12 conflict-split-site
] with-scope ] unit-test


! Resolve a local split-register cycle in parallel. Sequential activation
! would duplicate one value; the checker requires both original SSA tokens.
{ t } [ [ [let
    init-test-allocation drop
    int-rep 3 set-rep-of
    [
        1 11 ##load-integer,
        2 22 ##load-integer,
        3 1 2 ##sub,
        ##return,
    ] V{ } make insns>cfg :> graph
    graph cfg set graph number-instructions
    graph snapshot-value-flow :> snapshot
    int-regs machine-registers at :> regs
    regs first :> r0 regs second :> r1 regs third :> r2
    1 { 4 } test-interval r1 >>reg int-rep >>reload-rep
        r0 backtracking-register-home boa >>reload-from
    2 { 4 } test-interval r0 >>reg int-rep >>reload-rep
        r1 backtracking-register-home boa >>reload-from
    2array prepare-backtracking-moves
    graph cfg>insns :> insns
    insns first r0 >>dst drop
    insns second r1 >>dst drop
    insns third r2 >>dst r1 >>src1 r0 >>src2 drop
    graph insert-backtracking-moves
    graph snapshot check-value-flow
    t
] ] with-scope ] unit-test

:: backtracking-phi-pressure ( -- quot )
    40 <iota> [ 1 + >float '[ _ float+ ] ] map :> positive
    40 <iota> [ 1 + >float '[ _ float- ] ] map :> negative
    '[ positive cleave ] :> positive-branch
    '[ negative cleave ] :> negative-branch
    39 [ \ float+ ] replicate >quotation :> reduction
    '[ [ { float } declare ] dip
        positive-branch negative-branch if reduction call ] ;

! These are different values on the two incoming paths, not copies of a
! leader. Native code exercises shared homes and SSA edge move reification.
{ 920.0 -720.0 } [
    backtracking-allocator register-allocator [
        2.5 t backtracking-phi-pressure compile-call
        2.5 f backtracking-phi-pressure compile-call
    ] with-variable
] unit-test

{ t } [
    backtracking-allocator register-allocator [
        backtracking-phi-pressure measure-compilation
        "procedures" of first "allocation" of
        "bundle-merges" of 0 >
    ] with-variable
] unit-test


! A canonical no-use spill bundle gets one non-evicting second chance.
! Other registers may become free after the main eviction queue splits its
! occupants. Here the required fragments already have their assignments.
{ 1 t t } [ [ [let
    init-test-allocation drop
    [ 51 [ ##branch, ] times ] V{ } make insns>cfg :> graph
    graph cfg set graph number-instructions graph prepare-backtracking-points
    int-regs machine-registers at 2 head :> bank
    int-regs bank 2array 1array :> available
    1 { 0 100 } test-interval 1array available backtracking-allocation drop
    backtracking-original-intervals get first clone :> original
    1 { 0 } test-interval V{ { 0 1 } } clone >>ranges
        bank first >>reg int-rep >>spill-rep
        1 int-rep assign-spill-slot >>spill-to :> before
    1 { 100 } test-interval bank first >>reg int-rep >>reload-rep
        1 int-rep assign-spill-slot >>reload-from :> after
    original 1array backtracking-original-intervals set
    V{ } clone assigned-bundles set
    available [ [ <register-occupancy> ] H{ } map>assoc ] assoc-map bundle-occupancy set
    before after 2array <allocation-bundle> bank first assign-bundle
    2 { 50 } test-interval V{ { 40 60 } } clone >>ranges
    1array <allocation-bundle> bank first assign-bundle
    before after 2array allocate-second-chance :> assigned
    assigned available check-allocated-intervals
    backtracking-second-chance-assignments get
    assigned [ uses>> empty? ] any?
    before spill-to>> not after reload-from>> backtracking-register-home? and
] ] with-scope ] unit-test


! Productive cross-vreg copy merging needs distinct early-use/late-def
! phases. The following arithmetic result has different bits but can reuse
! its dying first input. Preserve every original SSA identity in the bundle.
{ 11 t t } [ [ [let
    init-validation-representations
    [
        ##prologue,
        1 D: 0 ##peek,
        2 1 int-rep ##copy,
        3 2 int-rep ##copy,
        4 3 1 tag-fixnum ##add-imm,
        4 D: 0 ##replace,
        ##epilogue, ##return,
    ] V{ } make insns>cfg backtracking-allocator compile-validation-cfg :> word
    10 word execute( x -- result )
    backtracking-merges get 3 >=
    { 1 2 3 4 } [ dup leader = ] all?
] ] with-scope ] unit-test

! A split between consecutive late/early uses retains both mandatory uses.
! The legacy synchronization splitter intentionally removes its cut point;
! applying that convention here would silently drop the use at point 3.
{ { 3 } { 4 } } [ [ [let
    init-test-allocation drop
    t backtracking-phase-mode? set
    H{ { 3 t } } backtracking-late-points set
    H{ } clone spill-slots set
    1 { 3 4 } test-interval 3 split-for-bundle
    [ uses>> [ n>> ] map >array ] bi@
] ] with-scope ] unit-test


! Keep the hot cluster together when a preceding loop-depth transition has
! a cheaper store/reload boundary inside the same obstruction-free prefix.
{ 19 1 } [ [ [let
    init-test-allocation drop
    H{ { 0 1 } { 10 1 } { 20 8 } { 30 8 } { 40 8 } } spill-site-weights set
    0 backtracking-cluster-splits set
    1 { 0 10 20 30 40 } test-interval 1array <allocation-bundle>
    41 conflict-split-site
    backtracking-cluster-splits get
] ] with-scope ] unit-test

! When the first use is already obstructed, peel that mandatory use. The
! next queue iterations reach a minimal fragment; no empty-prefix promise.
{ 9 } [ [
    init-test-allocation drop
    1 { 0 10 20 30 } test-interval 1array <allocation-bundle>
    0 conflict-split-site
] with-scope ] unit-test

! Alternating mandatory uses repeatedly obstruct each other's first free
! prefix. The per-spillset budget must switch to a direct minimal partition,
! while preserving every use exactly and assigning the single register.
{ t t } [ [ [let
    init-test-allocation :> bank
    1 200 <iota> [ 4 * ] map test-interval
    2 200 <iota> [ 4 * 2 + ] map test-interval 2array :> input
    input required-register-uses :> expected
    input bank backtracking-allocation :> assigned
    assigned bank check-allocated-intervals
    assigned expected check-register-uses
    backtracking-split-budget-exhaustions get 0 >
    backtracking-minimal-splits get 100 >
] ] with-scope ] unit-test


{ 8 8 t } [ [
    H{ { 0 8 } } clone spill-site-weights set
    H{ { 0 t } } clone cold-definition-sites set
    prepare-backtracking-phase-weights
    0 spill-site-weights get at 1 spill-site-weights get at
    1 cold-definition-sites get key?
] with-scope ] unit-test


! A parallel transition at a phi's original position must execute even
! though assignment emits no machine instruction for the phi itself.
{ t t } [ [ [let
    init-test-allocation drop
    1 { 0 } test-interval 1 >>reg int-rep >>reload-rep
        0 backtracking-register-home boa >>reload-from
    2 { 0 } test-interval 0 >>reg int-rep >>reload-rep
        1 backtracking-register-home boa >>reload-from
    2array prepare-backtracking-moves
    0 backtracking-local-moves get at :> prefix
    { } init-assignment
    backtracking-local-moves get clone phase-insn-prefixes set
    [ T{ ##phi { insn# 0 } } assign-phase-insn ] V{ } make
    prefix sequence=
    phase-insn-prefixes get assoc-empty?
] ] with-scope ] unit-test

! GC saves must observe the transitioned register, so the transport precedes
! the save/GC/restore sequence generated for the same original instruction.
{ t t t t t } [ [ [let
    init-test-allocation drop
    tagged-rep 1 set-rep-of
    H{ { 1 1 } } clone leader-map set
    1 { 0 2 } test-interval
        1 >>reg tagged-rep >>spill-rep
        dup uses>> [ tagged-rep >>use-rep drop ] each
    1array init-assignment
    [ 1 0 tagged-rep ##copy, ] V{ } make :> prefix
    prefix 0 associate phase-insn-prefixes set
    [ T{ ##call-gc { insn# 0 }
        { gc-map T{ gc-map { gc-roots { 1 } } { derived-roots H{ } } } } } clone
      assign-phase-insn ] V{ } make :> emitted
    emitted first ##copy?
    emitted second ##spill?
    emitted third ##call-gc?
    emitted fourth ##reload?
    phase-insn-prefixes get assoc-empty?
] ] with-scope ] unit-test

! Real IPv6 lowering has three phis followed by an FFI clobber. Second
! chance allocation moves two phi results at another phi's removed point;
! losing those copies left htons' root slots holding stale registers.
{ t } [
    backtracking-allocator register-allocator [
        t check-allocation? set t check-ssa? set
        M\ ipv6 make-sockaddr measure-compilation drop
        { 0 80 } [| port |
            "0:0:0:0:0:0:0:1" port <inet6> :> address
            address M\ ipv6 make-sockaddr def>> compile-call
            address parse-sockaddr address =
        ] all?
    ] with-variable
] unit-test


! An early-use fragment may end at 424 and share its dying register with
! the result at late phase 425. A later range in the original interval must
! not let spill trimming extend the first range across that liveness hole.
{ V{ { 424 424 } } } [ [ [let
    init-test-allocation drop
    t backtracking-phase-mode? set
    1 { 424 } test-interval
        V{ { 424 424 } { 500 510 } } >>ranges
    phase-spill-before ranges>>
] ] with-scope ] unit-test

! Synchronization splitting must preserve the same bound BEFORE shared
! spill trimming; trimming twice had already lost the original hole.
{ V{ { 424 424 } } } [ [ [let
    init-test-allocation drop
    t backtracking-phase-mode? set
    1 { 424 510 } test-interval
        V{ { 424 424 } { 500 510 } } >>ranges
    T{ sync-point { n 502 } } split-at-sync first ranges>>
] ] with-scope ] unit-test

! Exercise the GC transport with the independent original-value checker,
! then deliberately reproduce the old copy-after-save ordering.
:: gc-transition-fixture ( -- graph snapshot )
    init-test-allocation registers set
    tagged-rep 1 set-rep-of
    H{ { 1 1 } } clone leader-map set
    [
        1 { 1 2 3 } ##load-reference,
        ##call-gc new <gc-map> >>gc-map ,
        1 D: 0 ##replace,
        ##return,
    ] V{ } make insns>cfg :> graph
    graph cfg set graph number-instructions
    graph snapshot-value-flow :> snapshot
    1 { 1 } test-interval 0 >>reg :> before
    before uses>> first f >>use-rep tagged-rep >>def-rep drop
    1 { 2 4 } test-interval 1 >>reg tagged-rep >>reload-rep
        0 backtracking-register-home boa >>reload-from :> after
    after uses>> [ tagged-rep >>use-rep drop ] each
    before after 2array :> intervals
    intervals prepare-backtracking-moves
    graph intervals assign-backtracking-registers
    graph snapshot ;

{ } [ [ gc-transition-fixture check-value-flow ] with-scope ] unit-test

[
    [ [let
        gc-transition-fixture :> ( graph snapshot )
        graph entry>> instructions>> :> instructions
        instructions second :> copy
        instructions third 1 instructions set-nth
        copy 2 instructions set-nth
        graph snapshot check-value-flow
    ] ] with-scope
] [ invalid-allocation-gc-root? ] must-fail-with

:: prefix-context-fixture ( missing-point? -- failed? restored? published? )
    init-test-allocation registers set
    { T{ ##return } } insns>cfg :> graph
    graph cfg set graph compute-live-sets graph number-instructions
    H{ { "outer" "sentinel" } } clone :> previous
    previous phase-insn-prefixes set
    missing-point? [ { } 999 associate ] [ H{ } clone ] if
    backtracking-local-moves set
    [ graph { } assign-backtracking-registers f ] [
        dup unconsumed-backtracking-moves? [ drop t ] [ rethrow ] if
    ] recover
    phase-insn-prefixes get previous eq?
    graph entry>> machine-live-ins get key? ;

! Restoring only the prefix binding must retain assignment's new edge maps,
! on both success and an unconsumed-prefix failure.
{ f t t } [ [ f prefix-context-fixture ] with-scope ] unit-test
{ t t t } [ [ t prefix-context-fixture ] with-scope ] unit-test

! The original hidden callback result address can be live across Factor
! calls in memory. Second-chance residency must exclude every point of a
! skipped kill block, and a successor entry needs its own memory reload
! because the call block has no outgoing register assignment map.
{ V{ { 0 3 } { 8 11 } } t } [ [ [let
    init-test-allocation drop
    t backtracking-phase-mode? set
    H{ } clone spill-slots set
    V{ T{ ##branch } T{ ##branch } } clone 0 insns>block :> entry
    V{ T{ ##call } T{ ##branch } } clone 1 insns>block
    t >>kill-block? :> call-block
    V{ T{ ##branch } T{ ##branch } } clone 2 insns>block :> done
    entry call-block connect-bbs call-block done connect-bbs
    entry done connect-bbs
    entry block>cfg :> graph
    graph cfg set graph number-instructions graph prepare-backtracking-points
    1 { 0 11 } test-interval { } uncovered-ranges
    1 { 8 11 } gap-interval reload-from>> spill-slot?
] ] with-scope ] unit-test

! Independent slow complement oracle: scan all allocated original identities
! and subtract every occupied point, including call/GC/kill-block barriers.
:: slow-uncovered-points ( interval allocated -- points )
    allocated [ vreg>> interval vreg>> = ] filter
    [ ranges>> ] map concat backtracking-barriers get append :> occupied
    interval ranges>> [ first2 over - 1 + <iota> swap '[ _ + ] map ] map concat
    [| point | occupied [ point swap first2 between? ] any? not ] filter ;

{ t } [ [ [let
    init-test-allocation drop
    V{ { 5 5 } { 20 25 } { 23 29 } } backtracking-barriers set
    14 <iota> [| seed |
        1 { 0 40 } test-interval :> original
        seed 7 >= [ V{ { 0 12 } { 18 40 } } original ranges<< ] when
        1 { 0 4 } test-interval
        1 { 8 19 } test-interval
        1 { 30 40 } test-interval
        2 { 0 40 } test-interval 4array :> allocated
        seed 7 mod {
            { 5 [ original 1array ] }
            { 6 [ allocated last 1array ] }
            [ allocated swap head ]
        } case :> prefix
        original prefix uncovered-ranges
        [ first2 over - 1 + <iota> swap '[ _ + ] map ] map concat
        original prefix slow-uncovered-points sequence=
    ] all?
] ] with-scope ] unit-test
