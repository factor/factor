USING: accessors arrays assocs compiler.test compiler.cfg
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.checker compiler.cfg.linear-scan.live-intervals
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.occupancy
compiler.cfg.registers cpu.architecture kernel kernel.private libc locals math math.statistics namespaces
sequences tools.test vectors ;
IN: compiler.cfg.register-allocation.greedy.tests

:: test-interval ( vreg ranges positions -- interval )
    vreg <live-interval> ranges >vector >>ranges
    positions [ <vreg-use> int-rep >>use-rep ] map >vector >>uses
    dup first-use f >>use-rep int-rep >>def-rep drop ;

: test-registers ( -- registers )
    machine-registers int-regs of first 1array int-regs swap 2array 1array ;

: init-test ( -- )
    f f <basic-block> <cfg> cfg set
    H{ { 1 int-rep } { 2 int-rep } { 3 int-rep } } representations set
    H{ } clone greedy-use-weights set
    { } greedy-region-boundaries set
    t check-allocation? set ;

:: allocate-test ( intervals -- intervals' )
    intervals required-register-uses :> required
    intervals test-registers greedy-allocate-intervals
    dup test-registers check-allocated-intervals
    dup required check-register-uses ;

! Arbitrary-order unions share one register through a lifetime hole.
{ 2 f } [
    init-test
    1 { { 0 2 } { 10 12 } } { 0 2 10 12 } test-interval
    2 { { 4 8 } } { 4 8 } test-interval 2array allocate-test length
    "splits" greedy-statistics get at
] unit-test

! A live integer survives an actual libc call and string marshalling.
{ 12 } [
    greedy-allocator register-allocator [
        "greedy" [ dup length swap strlen + ] compile-call
    ] with-variable
] unit-test

! Enough live heap allocation to exercise collection with compiled roots.
{ 10880000 } [
    greedy-allocator register-allocator [
        [ 20000 [ 32 17 <array> ] replicate [ sum ] map sum ] compile-call
    ] with-variable
] unit-test

! The long interval is allocated first, then evicted by the dense one.
! Its second attempt splits around the dense region rather than falling
! back to the linear scan allocator.
{ t t t } [
    init-test
    1 { { 0 20 } } { 0 20 } test-interval
    2 { { 6 10 } } { 6 8 10 } test-interval 2array allocate-test
    length 2 >
    "evictions" greedy-statistics get at 0 >
    "splits" greedy-statistics get at 0 >
] unit-test

! Static loop weights change spill costs, independently of queue size.
{ t } [
    init-test
    H{ { 6 8 } { 10 8 } } greedy-use-weights set
    1 { { 0 4 } } { 0 4 } test-interval spill-weight
    2 { { 6 10 } } { 6 10 } test-interval spill-weight <
] unit-test

! A loop boundary is preferred over the widest use gap.
{ 7 } [
    init-test { { 7 1 } } greedy-region-boundaries set
    1 { { 0 40 } } { 0 8 10 40 } test-interval region-split
] unit-test

! Pressure invokes the loop-boundary splitter and preserves every use.
{ t } [
    init-test { { 7 1 } } greedy-region-boundaries set
    1 { { 0 40 } } { 0 6 12 40 } test-interval
    2 { { 8 10 } } { 8 10 } test-interval 2array allocate-test drop
    "region-splits" greedy-statistics get at 0 >
] unit-test

! Forced clobbers create an actual spill/reload pair in a shared slot.
{ 2 t } [
    init-test
    1 { { 0 20 } } { 0 20 } test-interval
    10 f sync-point boa 2array allocate-test
    dup length swap
    [ spill-to>> ] map sift first
    spill-slots get values first =
] unit-test

! An ordinary boxing destination survives the keep-dst clobber.
{ 1 f } [
    init-test
    1 { { 10 20 } } { 10 20 } test-interval
    10 t sync-point boa 2array allocate-test length
    "clobber-splits" greedy-statistics get at
] unit-test

! A stack-only ABI operand can occupy an atomic interval; it has no
! register fragment to split, but must retain a real spill-slot location.
{ 0 1 } [
    init-test
    1 { { 10 10 } } { 10 } test-interval
    dup first-use t >>spill-slot? drop
    10 f sync-point boa 2array allocate-test length
    spill-slots get assoc-size
] unit-test

! The same stack-only operand can precede its SSA definition in layout,
! leaving a wide range and no local use before the clobber to assign a slot.
{ 0 1 } [
    init-test
    1 { { 0 10 } } { 10 } test-interval
    dup first-use f >>def-rep int-rep >>use-rep t >>spill-slot? drop
    10 f sync-point boa 2array allocate-test length
    spill-slots get assoc-size
] unit-test

! Execute optimized machine code, covering loops, integer arithmetic,
! floating-point boxing and allocations (including their GC paths).
{ 4950 } [
    greedy-allocator register-allocator [
        100 [ 0 swap [ + ] each-integer ] compile-call
    ] with-variable
] unit-test

{ { 1.0 2.0 3.0 4.0 } } [
    greedy-allocator register-allocator [
        { 0.0 1.0 2.0 3.0 } [ [ 1.0 + ] map ] compile-call
    ] with-variable
] unit-test

! More simultaneous float values than either ARM64 or x86-64 can hold.
:: pressure-kernel ( x -- value )
    x { float } declare :> y
    y 1.0 + :> a1
    y 2.0 + :> a2
    y 3.0 + :> a3
    y 4.0 + :> a4
    y 5.0 + :> a5
    y 6.0 + :> a6
    y 7.0 + :> a7
    y 8.0 + :> a8
    y 9.0 + :> a9
    y 10.0 + :> a10
    y 11.0 + :> a11
    y 12.0 + :> a12
    y 13.0 + :> a13
    y 14.0 + :> a14
    y 15.0 + :> a15
    y 16.0 + :> a16
    y 17.0 + :> a17
    y 18.0 + :> a18
    y 19.0 + :> a19
    y 20.0 + :> a20
    y 21.0 + :> a21
    y 22.0 + :> a22
    y 23.0 + :> a23
    y 24.0 + :> a24
    y 25.0 + :> a25
    y 26.0 + :> a26
    y 27.0 + :> a27
    y 28.0 + :> a28
    y 29.0 + :> a29
    y 30.0 + :> a30
    y 31.0 + :> a31
    y 32.0 + :> a32
    a1 a17 *
    a2 a18 * +
    a3 a19 * +
    a4 a20 * +
    a5 a21 * +
    a6 a22 * +
    a7 a23 * +
    a8 a24 * +
    a9 a25 * +
    a10 a26 * +
    a11 a27 * +
    a12 a28 * +
    a13 a29 * +
    a14 a30 * +
    a15 a31 * +
    a16 a32 * + ;

{ 5092.0 } [
    greedy-allocator register-allocator [
        2.5 \ pressure-kernel def>> compile-call
    ] with-variable
] unit-test

! Eviction reuses cached costs; a split mutates its input and must discard
! that cache entry before computing child priorities from shortened ranges.
{ t } [
    init-test
    1 { { 0 20 } } { 0 20 } test-interval
    2 { { 6 10 } } { 6 8 10 } test-interval 2array allocate-test drop
    greedy-costs get [ swap greedy-priority = ] assoc-all?
] unit-test

! Stages never move backwards, even when a displaced interval is requeued.
{ 2 } [
    init-test { } allocate-test drop
    1 { { 0 2 } } { 0 2 } test-interval
    dup local-stage advance-stage dup assign-stage advance-stage interval-stage
] unit-test

! The eviction cascade is a strict partial order; equal/younger victims
! cannot bounce an interval back to the register it just lost.
{ { f f t t } } [
    init-test { } allocate-test drop
    1 { { 0 2 } } { 0 2 } test-interval
    2 { { 0 2 } } { 0 2 } test-interval
    [| incoming victim |
        2 incoming interval-progress cascade<<
        { 2 3 1 0 } [ victim interval-progress cascade<< incoming victim cascade-safe? ] map
    ] call
] unit-test

: init-recolor-test ( -- )
    init-test
    H{ { 1 int-rep } { 2 int-rep } { 3 int-rep } { 4 int-rep } } representations set
    { } H{ { int-regs { 10 11 } } } greedy-allocate-intervals drop ;

! This requires two recursive moves: B:r10 -> r11 displaces C, then
! C:r11 -> r10 fits between A's ranges. D is already fixed on r11.
{ t 10 11 10 11 } [
    init-recolor-test
    1 { { 0 2 } { 10 12 } } { 0 2 10 12 } test-interval
    2 { { 0 6 } } { 0 6 } test-interval
    3 { { 4 8 } } { 4 8 } test-interval
    4 { { 10 12 } } { 10 12 } test-interval
    [| a b c d |
        b 10 greedy-assign c 11 greedy-assign d 11 greedy-assign
        a last-chance-recolor
        a reg>> b reg>> c reg>> d reg>>
    ] call
] unit-test

! An impossible recolor restores exact index entries and insertion serials,
! union order and every physical register, after exploring both candidates.
{ f t t f 10 11 } [
    init-recolor-test
    1 { { 0 10 } } { 0 10 } test-interval
    2 { { 0 10 } } { 0 10 } test-interval
    3 { { 0 10 } } { 0 10 } test-interval
    [| a b c |
        b 10 greedy-assign c 11 greedy-assign
        greedy-occupancies get [ clone-occupancy ] assoc-map
        greedy-unions get [ clone ] assoc-map
        [| occupancies unions |
            a last-chance-recolor
            occupancies greedy-occupancies get =
            unions greedy-unions get =
            a reg>> b reg>> c reg>>
        ] call
    ] call
] unit-test

! Physical copy hints affect register choice before eviction/spilling.
{ { 11 10 } } [
    init-recolor-test
    1 { { 0 2 } } { 0 2 } test-interval
    dup interval-progress 11 >>hint drop allocation-order
] unit-test
