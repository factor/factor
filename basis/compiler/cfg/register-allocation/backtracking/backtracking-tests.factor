USING: accessors arrays assocs combinators compiler.test compiler.cfg compiler.cfg.metrics
compiler.cfg.register-allocation compiler.cfg.register-allocation.backtracking
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.registers
cpu.architecture kernel kernel.private locals math math.private namespaces sequences tools.test
vectors memory ;
IN: compiler.cfg.register-allocation.backtracking.tests

:: test-interval ( vreg positions -- interval )
    vreg <live-interval>
    positions first positions last 2array 1vector >>ranges
    positions [ <vreg-use> int-rep >>use-rep ] map >vector >>uses ;

: init-test-allocation ( -- registers )
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
