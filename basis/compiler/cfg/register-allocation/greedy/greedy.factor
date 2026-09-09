! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg.linear-scan
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering compiler.cfg.linear-scan.ranges
compiler.cfg.linear-scan.resolve compiler.cfg.utilities
compiler.cfg.instructions compiler.cfg.ssa.destruction.leaders
compiler.cfg.linearization compiler.cfg.loop-detection
compiler.cfg.register-allocation compiler.cfg.ssa.destruction
compiler.cfg.register-allocation.occupancy hashtables.identity
heaps kernel locals math math.functions math.order namespaces sequences sorting vectors ;
IN: compiler.cfg.register-allocation.greedy

! Unlike linear scan, these sets contain all assigned intervals, including
! intervals before and after the interval currently being allocated.
SINGLETON: greedy-allocator

SYMBOLS: greedy-queue greedy-registers greedy-unions greedy-statistics
greedy-use-weights greedy-region-boundaries greedy-occupancies greedy-costs
 greedy-progress-map greedy-cascade-counter greedy-copy-hints greedy-vreg-unions
 greedy-recolor-fixed greedy-recolor-budget ;

! Stages advance monotonically. Splits must reduce the number of uses; spill
! products are minimal and cannot be evicted or split indefinitely.
CONSTANT: assign-stage 0
CONSTANT: region-stage 1
CONSTANT: local-stage 2
CONSTANT: spill-stage 3
CONSTANT: done-stage 4
TUPLE: greedy-progress stage cascade hint ;

: interval-progress ( interval -- progress )
    greedy-progress-map get [ drop assign-stage 0 f greedy-progress boa ] cache ;

: interval-stage ( interval -- stage ) interval-progress stage>> ;

:: advance-stage ( interval stage -- )
    interval interval-progress [ stage max ] change-stage drop ;

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

: cached-priority ( interval -- priority )
    greedy-costs get [ greedy-priority ] cache ;

: cached-spill-weight ( interval -- weight ) cached-priority second ;

: greedy-enqueue ( interval -- )
    f >>reg dup cached-priority
    over interval-stage assign-stage = [ 1 ] [ 0 ] if prefix
    greedy-queue get heap-push ;

: register-union ( interval reg -- intervals )
    [ interval-reg-class ] dip 2array greedy-unions get at ;

: register-index ( interval reg -- occupancy )
    [ interval-reg-class ] dip 2array greedy-occupancies get at ;

:: register-conflicts ( interval reg -- conflicts )
    interval ranges>> interval reg register-index occupancy-conflicts ;

:: hint-scores ( interval -- scores )
    H{ } clone :> scores
    interval interval-progress hint>> [ 1 swap scores set-at ] when*
    interval vreg>> greedy-copy-hints get at [| hint |
        hint second interval ranges>> ranges-cover? [
            hint first greedy-vreg-unions get at [| peer |
                hint second peer ranges>> ranges-cover? [
                    hint third peer reg>> scores at 0 or +
                    peer reg>> scores set-at
                ] when
            ] each
        ] when
    ] each scores ;

:: hint-score ( interval reg -- score )
    reg interval hint-scores at 0 or ;

:: allocation-order ( interval -- regs )
    interval hint-scores :> scores
    interval interval-reg-class greedy-registers get at
    [ scores at 0 or neg ] sort-by ;

:: greedy-assign ( interval reg -- )
    interval reg >>reg interval reg register-union push
    interval interval ranges>> interval reg register-index occupy-ranges
    interval interval vreg>> greedy-vreg-unions get push-at
    interval reg hint-score 0 > [ "hint-assignments" greedy-count ] when
    "assignments" greedy-count ;

:: greedy-unassign ( interval -- )
    interval reg>> :> reg
    interval reg register-union interval swap remove-eq! drop
    interval interval reg register-index release-ranges
    interval interval vreg>> greedy-vreg-unions get at remove-eq! drop
    interval f >>reg drop ;

:: cascade-safe? ( interval victim -- ? )
    interval interval-progress cascade>> :> cascade
    victim interval-progress cascade>> :> other
    cascade 0 = other cascade < or ;

:: evictable-victim? ( interval victim reg -- ? )
    victim interval-stage done-stage <
    interval victim cascade-safe? and [
        interval cached-spill-weight victim cached-spill-weight >
        interval reg hint-score 0 >
        victim reg hint-score 0 = and
        victim interval-stage spill-stage < and or
    ] [ f ] if ;

:: evictable? ( interval conflicts -- ? )
    conflicts [| victim | interval victim victim reg>> evictable-victim? ] all? ;

: eviction-cost ( conflicts -- cost ) [ cached-spill-weight ] map-sum ;

:: candidate-cost ( interval reg conflicts -- cost )
    conflicts [ reg hint-score ] map-sum
    interval reg hint-score -
    conflicts 0 [ cached-spill-weight max ] reduce
    conflicts eviction-cost 3array ;

:: eviction-cascade ( interval -- cascade )
    interval interval-progress :> progress
    progress cascade>> dup 0 = [
        drop greedy-cascade-counter inc
        greedy-cascade-counter get dup progress cascade<<
    ] when ;

:: greedy-evict ( interval reg -- )
    interval eviction-cascade :> cascade
    interval reg register-conflicts [| victim |
        victim reg hint-score 0 > [ "broken-hints" greedy-count ] when
        cascade victim interval-progress cascade<<
        victim greedy-unassign
        victim greedy-enqueue
        "evictions" greedy-count
    ] each
    interval reg greedy-assign ;

! Last-chance recoloring is a bounded augmenting search. Every failed branch
! restores complete occupancy state (including stable conflict order), register
! fields and diagnostics. No interval is split or queued during this search.
TUPLE: greedy-snapshot unions occupancies vregs fixed statistics ;

: clone-occupancy ( occupancy -- copy )
    clone [ clone ] change-entries ;

: save-greedy-state ( -- snapshot )
    greedy-unions get [ clone ] assoc-map
    greedy-occupancies get [ clone-occupancy ] assoc-map
    greedy-vreg-unions get [ clone ] assoc-map
    greedy-recolor-fixed get clone
    greedy-statistics get clone greedy-snapshot boa ;

:: restore-greedy-state ( snapshot -- )
    greedy-unions get values [ [ f >>reg drop ] each ] each
    snapshot unions>> dup greedy-unions set [| key intervals |
        intervals [ key second >>reg drop ] each
    ] assoc-each
    snapshot occupancies>> greedy-occupancies set
    snapshot vregs>> greedy-vreg-unions set
    snapshot fixed>> greedy-recolor-fixed set
    snapshot statistics>> greedy-statistics set ;

DEFER: recolor-interval

:: recolor-on-register ( interval reg depth -- ? )
    interval reg register-conflicts :> conflicts
    conflicts empty? [ interval reg greedy-assign t ] [
        depth 0 > conflicts length 8 <= and
        conflicts [ greedy-recolor-fixed get key? not ] all? and [
            save-greedy-state :> saved
            conflicts [ greedy-unassign ] each
            interval reg greedy-assign
            t interval greedy-recolor-fixed get set-at
            conflicts [ depth 1 - recolor-interval ] all? [
                t
            ] [
                saved restore-greedy-state
                "recolor-rollbacks" greedy-count f
            ] if
        ] [ f ] if
    ] if ;

:: recolor-interval ( interval depth -- ? )
    greedy-recolor-budget get 0 > [
        greedy-recolor-budget dec
        interval allocation-order [ interval swap depth recolor-on-register ] any?
        dup [ t interval greedy-recolor-fixed get set-at ] when
    ] [ f ] if ;

:: last-chance-recolor ( interval -- ? )
    "recolor-attempts" greedy-count
    32 <identity-hashtable> greedy-recolor-fixed set
    64 greedy-recolor-budget set
    interval 5 recolor-interval
    dup [ "recolor-successes" greedy-count ] when ;

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
    ! split-for-spill mutates its input; child priorities must be recomputed.
    interval greedy-costs get delete-at
    interval region-split :> position!
    position [ "region-splits" greedy-count ] [
        interval use-gap [ interval single-use-split ] unless* position!
    ] if
    position [
        interval interval-stage 1 + spill-stage min :> stage
        interval position split-for-spill [
            [ dup stage advance-stage greedy-enqueue ] when*
        ] bi@
        "splits" greedy-count
    ] [ interval greedy-register-pressure ] if ;

:: spill-to-minimal-ranges ( interval -- )
    interval greedy-costs get delete-at
    interval :> remaining!
    [ remaining uses>> length 1 > ] [
        remaining remaining uses>> second n>> 1 - split-for-spill
        remaining!
        spill-after dup done-stage advance-stage greedy-enqueue
        "spill-products" greedy-count
    ] while
    remaining spill-after spill-before
    dup done-stage advance-stage greedy-enqueue
    "spill-products" greedy-count ;

:: greedy-allocate-one ( interval -- )
    f :> cheapest!
    interval allocation-order [| reg |
        interval reg register-conflicts :> conflicts
        conflicts empty? [
            interval reg greedy-assign t
        ] [
            interval interval-stage region-stage = [ ] [
                interval conflicts evictable? [
                    interval reg conflicts candidate-cost :> cost
                    cheapest [ cost cheapest second before? ] [ t ] if [
                        reg cost 2array cheapest!
                    ] when
                ] when
            ] if f
        ] if
    ] any? [
        cheapest [ first interval swap greedy-evict ] [
            interval interval-stage {
                { 0 [
                    interval region-stage advance-stage
                    interval greedy-enqueue "stage-deferrals" greedy-count
                ] }
                { 4 [ interval last-chance-recolor [ interval greedy-register-pressure ] unless ] }
                { 3 [ interval last-chance-recolor [ interval spill-to-minimal-ranges ] unless ] }
                [ drop interval greedy-split ]
            } case
        ] if*
    ] unless ;

! Calls and boxing instructions impose Factor-specific clobbers. Split them
! before arbitrary-order allocation, preserving the baseline's keep-dst rule.
:: reserve-clobber-slot ( interval sync -- )
    sync n>> interval find-use [| use |
        use spill-slot?>> [
            interval vreg>> use def-rep>> use use-rep>> or
            assign-spill-slot drop
        ] when
    ] when* ;

:: memory-only-at-clobber? ( interval sync -- ? )
    interval uses>> length 1 = [
        interval first-use [ spill-slot?>> ] [ n>> sync n>> = ] bi and
    ] [ f ] if ;

:: split-at-clobber ( interval sync -- fragments )
    interval sync reserve-clobber-slot
    sync n>> interval covers?
    sync interval spill-at-sync-point? and [
        interval sync memory-only-at-clobber? [
            ! The ABI consumes/defines the slot directly. No register use
            ! survives, including when the entire interval is atomic.
            { }
            "memory-only-clobbers" greedy-count
        ] [
            interval sync n>> already-spilled-atomic-use? [ interval 1array ] [
                interval sync n>> split-for-spill 2array sift
                "clobber-splits" greedy-count
            ] if
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
    H{ } clone greedy-occupancies set
    32 <identity-hashtable> greedy-costs set
    32 <identity-hashtable> greedy-progress-map set
    0 greedy-cascade-counter set
    H{ } clone greedy-vreg-unions set
    registers [| class regs |
        regs [| reg |
            V{ } clone class reg 2array greedy-unions get set-at
            <register-occupancy> class reg 2array greedy-occupancies get set-at
        ] each
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
    H{ } clone greedy-copy-hints set
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
            insn ##copy? [
                insn src>> leader :> src
                insn dst>> leader :> dst
                src dst = [ ] [
                    dst insn insn#>> 8 depth ^ 3array src greedy-copy-hints get push-at
                    src insn insn#>> 8 depth ^ 3array dst greedy-copy-hints get push-at
                ] if
            ] when
        ] each
    ] each ;

:: (greedy-allocation-with-registers) ( cfg registers -- )
    cfg prepare-greedy-regions
    cfg compute-live-intervals :> original-intervals
    check-allocation? get [ original-intervals required-register-uses ] [ f ] if :> required
    original-intervals registers greedy-allocate-intervals :> intervals
    check-allocation? get [
        intervals registers check-allocated-intervals
        intervals required check-register-uses
    ] when
    cfg intervals assign-registers ;

: greedy-allocate-and-assign ( cfg -- )
    dup admissible-registers (greedy-allocation-with-registers) ;

: greedy ( cfg -- )
    {
        number-instructions
        greedy-allocate-and-assign
        resolve-data-flow
        check-numbering
    } apply-passes ;

! Public complete allocator kernel for independently selected legal banks.
:: greedy-allocation-with-registers ( cfg registers -- )
    cfg destruct-ssa
    cfg number-instructions
    cfg registers (greedy-allocation-with-registers)
    cfg resolve-data-flow
    cfg check-numbering ;

M: greedy-allocator allocate-cfg
    drop dup admissible-registers greedy-allocation-with-registers ;

M: greedy-allocator allocator-statistics
    drop greedy-statistics get H{ } or clone
    "llvm-style-greedy" "algorithm" pick set-at
    0 "fallback-count" pick set-at ;
