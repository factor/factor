! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg.linear-scan
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering compiler.cfg.linear-scan.ranges
compiler.cfg.linear-scan.resolve compiler.cfg.utilities
compiler.cfg.linearization compiler.cfg.loop-detection
compiler.cfg.register-allocation compiler.cfg.ssa.destruction
heaps kernel locals math math.functions math.order namespaces sequences sorting vectors ;
IN: compiler.cfg.register-allocation.greedy

! Unlike linear scan, these sets contain all assigned intervals, including
! intervals before and after the interval currently being allocated.
SINGLETON: greedy-allocator

SYMBOLS: greedy-queue greedy-registers greedy-unions greedy-statistics
greedy-use-weights greedy-region-boundaries ;

: greedy-count ( key -- ) greedy-statistics get inc-at ;

: interval-size ( interval -- n )
    ranges>> [ first2 swap - 1 + ] map-sum ;

: minimal-interval? ( interval -- ? )
    [ uses>> length 1 = ]
    [ [ live-interval-end ] [ live-interval-start ] bi - 1 <= ] bi and ;

: spill-weight ( interval -- weight )
    dup minimal-interval? [ drop 1/0. ] [
        [ uses>> [ n>> greedy-use-weights get at 1 or ] map-sum ]
        [ interval-size ] bi /
    ] if ;

: greedy-priority ( interval -- priority )
    [ interval-size ] [ spill-weight ] [ vreg>> neg ] tri 3array ;

: greedy-enqueue ( interval -- )
    f >>reg dup greedy-priority greedy-queue get heap-push ;

: register-union ( interval reg -- intervals )
    [ interval-reg-class ] dip 2array greedy-unions get at ;

:: register-conflicts ( interval reg -- conflicts )
    interval reg register-union
    [ interval intervals-intersect? ] filter ;

:: greedy-assign ( interval reg -- )
    interval reg >>reg interval reg register-union push
    "assignments" greedy-count ;

:: evictable? ( interval conflicts -- ? )
    interval spill-weight :> weight
    conflicts [ spill-weight weight < ] all? ;

: eviction-cost ( conflicts -- cost ) [ spill-weight ] map-sum ;

:: greedy-evict ( interval reg -- )
    interval reg register-conflicts [| victim |
        victim reg register-union victim swap remove-eq! drop
        victim greedy-enqueue
        "evictions" greedy-count
    ] each
    interval reg greedy-assign ;

! Split at the widest gap between uses. This preserves a cluster of nearby
! uses instead of immediately creating a separate reload for every use.
:: use-gap ( interval -- position/f )
    f :> position!
    0 :> widest!
    f :> previous!
    interval uses>> [ n>> ] map [| n |
        previous [
            n previous - widest > [
                n previous - widest!
                previous 1 + position!
            ] when
        ] when
        n previous!
    ] each
    position ;

! A one-use interval may still span blocks. Isolate its mandatory register
! use before declaring it unspillable. Edge resolution supplies its slot.
:: single-use-split ( interval -- position/f )
    interval first-use n>> :> n
    interval live-interval-start n < [ n 1 - ] [
        interval live-interval-end n 1 + > [ n 1 + ] [ f ] if
    ] if ;

ERROR: greedy-register-pressure interval ;

:: region-split ( interval -- position/f )
    greedy-region-boundaries get [| boundary |
        boundary first :> n
        interval first-use n>> n <
        interval last-use n>> n > and
    ] filter dup empty? [ drop f ] [
        [ second ] sort-by last first
    ] if ;

:: greedy-split ( interval -- )
    interval region-split :> position!
    position [ "region-splits" greedy-count ] [
        interval use-gap [ interval single-use-split ] unless* position!
    ] if
    position [
        interval position split-for-spill
        [ [ greedy-enqueue ] when* ] bi@
        "splits" greedy-count
    ] [ interval greedy-register-pressure ] if ;

:: greedy-allocate-one ( interval -- )
    interval interval-reg-class greedy-registers get at :> regs
    regs [ interval swap register-conflicts empty? ] find nip
    [ interval swap greedy-assign ] [
        regs [ interval swap register-conflicts interval swap evictable? ] filter
        dup empty? [ drop interval greedy-split ] [
            [ interval swap register-conflicts eviction-cost ] sort-by first
            interval swap greedy-evict
        ] if
    ] if* ;

! Calls and boxing instructions impose Factor-specific clobbers. Split them
! before arbitrary-order allocation, preserving the baseline's keep-dst rule.
:: split-at-clobber ( interval sync -- fragments )
    sync n>> interval covers?
    sync interval spill-at-sync-point? and [
        interval sync n>> already-spilled-atomic-use? [ interval 1array ] [
            interval sync n>> split-for-spill 2array sift
            "clobber-splits" greedy-count
        ] if
    ] [ interval 1array ] if ;

:: prepare-greedy-intervals ( intervals/sync-points -- intervals )
    intervals/sync-points [ live-interval-state? ] partition
    [ n>> ] sort-by :> syncs
    :> intervals
    intervals [| interval |
        syncs interval 1array [| fragments sync |
            fragments [ sync split-at-clobber ] map concat
        ] reduce
    ] map concat ;

:: greedy-allocate-intervals ( intervals/sync-points registers -- intervals )
    registers greedy-registers set
    H{ } clone spill-slots set
    H{ } clone greedy-statistics set
    H{ } clone greedy-unions set
    registers [| class regs |
        regs [| reg | V{ } clone class reg 2array greedy-unions get set-at ] each
    ] assoc-each
    <max-heap> greedy-queue set
    intervals/sync-points prepare-greedy-intervals [ greedy-enqueue ] each
    [ greedy-queue get heap-empty? ] [
        greedy-queue get heap-pop drop greedy-allocate-one
    ] until
    greedy-unions get values concat ;

! A static loop-depth estimate, not profile information. Bound the weight
! so deeply nested loops cannot swamp all other uses through huge integers.
:: prepare-greedy-regions ( cfg -- )
    cfg needs-loops
    H{ } clone greedy-use-weights set
    V{ } clone greedy-region-boundaries set
    0 :> previous-depth!
    cfg linearization-order [| bb |
        bb loop-nesting-at 3 min :> depth
        depth previous-depth = [ ] [
            bb block-from depth previous-depth - abs 2array
            greedy-region-boundaries get push
        ] if
        depth previous-depth!
        bb instructions>> [| insn |
            8 depth ^ insn insn#>> greedy-use-weights get set-at
        ] each
    ] each ;

:: greedy-allocate-and-assign ( cfg -- )
    cfg prepare-greedy-regions
    cfg admissible-registers :> registers
    cfg compute-live-intervals :> original-intervals
    check-allocation? get [ original-intervals required-register-uses ] [ f ] if :> required
    original-intervals registers greedy-allocate-intervals :> intervals
    check-allocation? get [
        intervals registers check-allocated-intervals
        intervals required check-register-uses
    ] when
    cfg intervals assign-registers ;

: greedy ( cfg -- )
    {
        number-instructions
        greedy-allocate-and-assign
        resolve-data-flow
        check-numbering
    } apply-passes ;

M: greedy-allocator allocate-cfg drop [ destruct-ssa ] [ greedy ] bi ;

M: greedy-allocator allocator-statistics
    drop greedy-statistics get H{ } or clone ;
