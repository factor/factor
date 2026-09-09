USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.build-stack-frame compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering compiler.cfg.linearization
compiler.cfg.loop-detection compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.spill-sites.fixtures
compiler.cfg.register-allocation.verifier compiler.cfg.registers compiler.cfg.utilities
compiler.codegen compiler.units cpu.architecture hashtables kernel layouts locals make math math.functions math.order
namespaces sequences tools.test vectors words ;
IN: compiler.cfg.register-allocation.spill-sites.tests

: position-uses ( -- uses )
    12 <iota> [ 2 * <vreg-use> int-rep >>use-rep ] map ;

{ 6 } [
    f spill-site-weights [ position-uses cooler-spill-site ] with-variable
] unit-test

! Median is hot; a balanced boundary in the cold suffix is cheaper.
{ 8 } [
    H{ { 6 8 } { 8 8 } { 10 8 } { 12 8 } { 14 8 } }
    spill-site-weights [ position-uses cooler-spill-site ] with-variable
] unit-test

: init-site-test ( -- )
    t backtracking-loop-spills? set
    t cold-spill-safe? set
    H{ { 1 int-rep } } clone representations set
    H{ { 0 1 } { 20 8 } } clone spill-site-weights set
    H{ { 0 t } } clone cold-definition-sites set
    H{ } clone established-cold-spills set
    0 loop-spill-site-count set
    0 cold-spill-store-count set ;

: cold-interval ( -- interval )
    1 <live-interval>
    0 <vreg-use> int-rep >>def-rep
    20 <vreg-use> int-rep >>use-rep 2array >vector >>uses
    V{ { 0 20 } } clone >>ranges ;

{ t f f } [ [
    init-site-test
    cold-interval cold-definition?
    cold-interval dup uses>> last t >>spill-slot? drop cold-definition?
    cold-interval dup uses>> last int-rep >>def-rep drop cold-definition?
] with-scope ] unit-test

! A unique cold def may be isolated once; the remaining fragment has no
! def and therefore goes through balanced splitting, even for huge loops.
{ 1 } [ [
    init-site-test
    cold-interval 1array prepare-cold-spills
    cold-interval backtracking-spill-site
] with-scope ] unit-test

{ f } [ [
    init-site-test
    { T{ ##call-gc } T{ ##return } } insns>cfg prepare-spill-sites
    cold-spill-safe? get
] with-scope ] unit-test

: read-only-fragment ( -- interval )
    cold-interval
    dup uses>> rest >vector >>uses
    0 <spill-slot> >>reload-from 0 <spill-slot> >>spill-to
    int-rep >>reload-rep int-rep >>spill-rep ;

: cold-defining-fragment ( -- interval )
    cold-interval
    dup uses>> first 1vector >>uses
    V{ { 0 1 } } clone >>ranges
    0 >>reg 0 <spill-slot> >>spill-to int-rep >>spill-rep ;

{ t f f f } [ [
    init-site-test cold-interval 1array prepare-cold-spills
    H{ { 1 T{ spill-slot { n 0 } } } } established-cold-spills set
    read-only-fragment redundant-cold-spill?
    read-only-fragment 8 <spill-slot> >>reload-from redundant-cold-spill?
    read-only-fragment double-rep >>spill-rep redundant-cold-spill?
    read-only-fragment dup uses>> first int-rep >>def-rep drop
    redundant-cold-spill?
] with-scope ] unit-test

{ f 1 } [ [
    init-site-test cold-interval 1array prepare-cold-spills
    cold-defining-fragment read-only-fragment 2array
    finish-loop-spills last spill-to>>
    cold-spill-store-count get
] with-scope ] unit-test

! A call split can leave the defining fragment's store in a hot body.
! The zero-iteration edge skips that store and the following reload, and
! enters the read-only fragment in its middle through a register copy.
! Its trailing store is still needed to initialize the subsequent reload.
{ t 0 } [ [
    init-site-test cold-interval 1array prepare-cold-spills
    cold-interval 0 >>reg 0 <spill-slot> >>spill-to int-rep >>spill-rep
    V{ { 0 21 } } >>ranges
    read-only-fragment 2array finish-loop-spills last spill-to>> spill-slot?
    cold-spill-store-count get
] with-scope ] unit-test

{ f f } [ [
    init-site-test cold-interval 1array prepare-cold-spills
    cold-defining-fragment f >>spill-to establishes-cold-spill?
    H{ } clone cold-definition-sites set
    cold-defining-fragment establishes-cold-spill?
] with-scope ] unit-test


{ t } [
    { f t } [| enabled? |
        40 8 5 enabled? loop-pressure-metrics drop :> word
        0 word execute( n -- checksum ) 4100 =
        1 word execute( n -- checksum ) 11180 = and
        3 word execute( n -- checksum ) 12220 = and
    ] all?
] unit-test

:: pressure-benefits? ( -- ? )
    40 8 5 f loop-pressure-metrics nip :> before
    40 8 5 t loop-pressure-metrics nip :> after
    { "loop-traffic" "spills" "code-bytes" }
    [| key | key before at key after at > ] all? ;

{ t } [ pressure-benefits? ] unit-test

:: clobber-pressure-results? ( nvalues enabled? -- ? )
    t loop-pressure-clobber? [
        nvalues 8 5 enabled? loop-pressure-metrics drop :> word
        nvalues nvalues 1 + * 2 /i :> constant
        0 word execute( n -- checksum ) constant 5 * =
        1 word execute( n -- checksum ) constant nvalues + 13 * = and
        3 word execute( n -- checksum ) constant nvalues 3 * + 13 * = and
    ] with-variable ;

! An unrelated non-GC clobber is preceded and followed by hot reads, while
! the zero-iteration path reaches several cold reads without calling it.
! Allocation/value-flow checks run before any native code is executed.
{ t } [
    { 8 16 24 } [| nvalues |
        { f t } [ nvalues swap clobber-pressure-results? ] all?
    ] all?
] unit-test

! Exact symbolic counterexample to the old deletion rule. The body path
! initializes the slot across a non-GC clobber; the bypass path carries the
! original value directly in a register. Both enter the read-only fragment
! at C1. Its store must initialize the later C2 reload on the bypass path.
:: bypass-store-example ( keep-store? -- graph snapshot )
    H{ { 1 int-rep } { 2 int-rep } { 3 int-rep }
        { 4 int-rep } { 5 int-rep } { 6 int-rep } } representations set
    [
        1 17 ##load-integer,
        2 0 ##load-integer,
        2 0 cc> ##compare-integer-imm-branch,
    ] V{ } make 0 insns>block :> entry
    [
        3 1 1 ##add-imm,
        f { } { } { } { } 0 0 [ ] ##alien-assembly,
        4 1 2 ##add-imm,
        ##branch,
    ] V{ } make 1 insns>block :> body
    [ 5 1 3 ##add-imm, 6 1 4 ##add-imm, ##return, ] V{ } make
    2 insns>block :> done
    entry body connect-bbs entry done connect-bbs body done connect-bbs
    entry block>cfg :> graph
    graph snapshot-value-flow :> snapshot
    body instructions>> :> body-insns
    [
        body-insns first ,
        1 int-rep 0 <spill-slot> ##spill,
        body-insns second ,
        1 int-rep 0 <spill-slot> ##reload,
        body-insns 2 tail %
    ] V{ } make body instructions<<
    done instructions>> :> exit-insns
    [
        exit-insns first ,
        keep-store? [ 1 int-rep 0 <spill-slot> ##spill, ] when
        1 int-rep 0 <spill-slot> ##reload,
        exit-insns rest %
    ] V{ } make done instructions<<
    graph snapshot ;

{ } [ [ t bypass-store-example check-value-flow ] with-scope ] unit-test

[ [ f bypass-store-example check-value-flow ] with-scope ]
[ bad-allocation-value? ] must-fail-with


! Early-only and phased definitions may expire at either of these adjacent
! points. Both stores occur after the definition and before the next insn;
! retaining the interval through another instruction is not this proof.
{ t t f } [ [
    init-site-test cold-interval 1array prepare-cold-spills
    cold-defining-fragment V{ { 0 0 } } clone >>ranges establishes-cold-spill?
    cold-defining-fragment establishes-cold-spill?
    cold-defining-fragment V{ { 0 2 } } clone >>ranges establishes-cold-spill?
] with-scope ] unit-test
