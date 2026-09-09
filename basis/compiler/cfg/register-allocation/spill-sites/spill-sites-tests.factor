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

{ t f f f } [ [
    init-site-test cold-interval 1array prepare-cold-spills
    read-only-fragment redundant-cold-spill?
    read-only-fragment 8 <spill-slot> >>reload-from redundant-cold-spill?
    read-only-fragment double-rep >>spill-rep redundant-cold-spill?
    read-only-fragment dup uses>> first int-rep >>def-rep drop
    redundant-cold-spill?
] with-scope ] unit-test

{ f 1 } [ [
    init-site-test cold-interval 1array prepare-cold-spills
    read-only-fragment 1array finish-loop-spills first spill-to>>
    cold-spill-store-count get
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
