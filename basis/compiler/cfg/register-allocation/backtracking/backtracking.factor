! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.linear-scan compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.ranges compiler.cfg.linear-scan.resolve
compiler.cfg.utilities compiler.cfg.register-allocation
compiler.cfg.ssa.destruction compiler.cfg.register-allocation.occupancy
compiler.cfg.register-allocation.spill-sites
cpu.architecture heaps kernel locals math
math.order namespaces sequences vectors ;
IN: compiler.cfg.register-allocation.backtracking

! An interval is a bundle of disjoint ranges already coalesced by SSA
! destruction. Unlike linear scan, the queue is ordered by size, and a
! later request can revoke an earlier assignment anywhere in the CFG.
TUPLE: allocation-bundle intervals weight priority ranges reg-class ;
SYMBOL: bundle-occupancy
SYMBOL: bundle-queue
SYMBOL: assigned-bundles
SYMBOL: backtracking-evictions
SYMBOL: backtracking-splits

: interval-size ( interval -- n )
    ranges>> [ first2 swap - 1 + ] map-sum ;

: minimal-interval? ( interval -- ? )
    [ uses>> length 1 = ]
    [ [ live-interval-start ] [ first-use n>> ] bi = ]
    [ [ live-interval-end ] [ last-use n>> 1 + ] bi <= ] tri and and ;

:: <allocation-bundle> ( intervals -- bundle )
    intervals [ interval-size ] map-sum :> size
    intervals intervals length 1 =
    intervals [ minimal-interval? ] all? and [ 1/0. ] [
        intervals backtracking-use-weight size /
    ] if size
    ! A queued/assigned bundle is immutable. Splitting discards the bundle;
    ! each child receives fresh range and cost metadata when enqueued.
    intervals length 1 = [ intervals first ranges>> ] [
        intervals [ ranges>> ] map concat
    ] if
    intervals first interval-reg-class allocation-bundle boa ;

: enqueue-bundle ( bundle -- )
    dup priority>> bundle-queue get heap-push ;

: enqueue-interval ( interval/f -- )
    [ 1array <allocation-bundle> enqueue-bundle ] when* ;

: bundle-reg-class ( bundle -- reg-class )
    reg-class>> ;

:: bundles-intersect? ( first-bundle second-bundle -- ? )
    first-bundle intervals>> [| interval |
        second-bundle intervals>> [ interval intervals-intersect? ] any?
    ] any? ;

: bundle-register-occupancy ( bundle reg -- occupancy )
    [ bundle-reg-class bundle-occupancy get at ] dip swap at ;

:: bundle-conflicts ( bundle reg -- conflicts )
    bundle ranges>> bundle reg bundle-register-occupancy occupancy-conflicts ;

: conflict-cost ( conflicts -- weight )
    0 [ weight>> max ] reduce ;

:: register-candidates ( bundle -- candidates )
    bundle bundle-reg-class registers get at [| reg |
        bundle reg bundle-conflicts :> conflicts
        reg conflicts conflicts conflict-cost 3array
    ] map ;

:: assign-bundle ( bundle reg -- )
    bundle intervals>> [ reg >>reg drop ] each
    bundle assigned-bundles get push
    bundle bundle ranges>> bundle reg bundle-register-occupancy occupy-ranges ;

: evict-bundle ( bundle -- )
    dup dup dup intervals>> first reg>> bundle-register-occupancy release-ranges
    dup assigned-bundles get remove-eq! drop
    dup intervals>> [ f >>reg drop ] each
    dup priority>> bundle-queue get heap-push
    backtracking-evictions inc ;

:: assign-with-eviction ( bundle candidate -- )
    candidate second [ evict-bundle ] each
    bundle candidate first assign-bundle ;

ERROR: unsatisfiable-register-pressure interval ;

! Each split reduces the number of uses in a bundle. Once only one use
! remains, trim away its live-through tails and connect them via a slot.
! Minimal intervals have infinite weight and can never evict each other.
:: split-single-interval ( interval -- )
    interval uses>> :> uses
    interval minimal-interval? [ interval unsatisfiable-register-pressure ] when
    backtracking-splits inc
    uses length 1 > [
        interval dup backtracking-spill-site split-for-spill
        [ enqueue-interval ] bi@
    ] [
        interval spill-after spill-before enqueue-interval
    ] if ;

: split-bundle ( bundle -- )
    intervals>> dup length 1 > [
        backtracking-splits inc [ enqueue-interval ] each
    ] [ first split-single-interval ] if ;

:: process-bundle ( bundle -- )
    f :> cheapest!
    bundle bundle-reg-class registers get at [| reg |
        bundle reg bundle-conflicts :> conflicts
        conflicts empty? [
            bundle reg assign-bundle t
        ] [
            conflicts conflict-cost :> cost
            cheapest [ cost cheapest third < ] [ t ] if [
                reg conflicts cost 3array cheapest!
            ] when f
        ] if
    ] any? [
        cheapest third bundle weight>> < [
            bundle cheapest assign-with-eviction
        ] [ bundle split-bundle ] if
    ] unless ;

! Calls have stack operands in Factor's lowered IR. Materialize slots for
! the operands removed at a sync point, including an atomic stack result.
:: sync-operand-slots ( interval sync -- )
    sync n>> interval find-use [| use |
        use def-rep>> [ interval vreg>> swap assign-spill-slot drop ] when*
        use use-rep>> [ interval vreg>> swap assign-spill-slot drop ] when*
    ] when* ;

:: split-at-sync ( interval sync -- intervals )
    sync n>> interval ranges>> ranges-cover?
    sync keep-dst?>> [ sync n>> interval find-use [ def-rep>> ] ?call not ] [ t ] if and
    [
        interval sync sync-operand-slots
        interval live-interval-start interval live-interval-end = [
            { }
        ] [
            interval sync n>> split-for-spill 2array sift
        ] if
    ] [ interval 1array ] if ;

:: prepare-bundles ( intervals/syncs -- intervals )
    intervals/syncs [ live-interval-state? ] partition :> ( intervals syncs )
    syncs intervals [| current sync |
        current [ sync split-at-sync ] map concat
    ] reduce ;

:: backtracking-allocation ( intervals/syncs machine-regs -- intervals )
    intervals/syncs prepare-cold-spills
    machine-regs registers set
    H{ } clone spill-slots set
    <max-heap> bundle-queue set
    V{ } clone assigned-bundles set
    machine-regs [ [ <register-occupancy> ] H{ } map>assoc ] assoc-map
    bundle-occupancy set
    0 backtracking-evictions set
    0 backtracking-splits set
    ! A common leader is a strong affinity: these fragments carry the same
    ! coalesced SSA value across call clobbers. Bundle them without removing
    ! mandatory spills. If pressure prevents assignment, unbundle first.
    H{ } clone :> groups
    intervals/syncs prepare-bundles [ dup vreg>> groups push-at ] each
    groups values [ <allocation-bundle> enqueue-bundle ] each
    bundle-queue get [ drop process-bundle ] slurp-heap
    assigned-bundles get [ intervals>> ] map concat finish-loop-spills ;

:: backtracking-allocate-and-assign ( cfg -- )
    cfg prepare-spill-sites
    cfg admissible-registers :> machine-regs
    cfg compute-live-intervals :> input
    check-allocation? get [ input required-register-uses ] [ f ] if :> uses
    input machine-regs backtracking-allocation :> intervals
    check-allocation? get [
        intervals machine-regs check-allocated-intervals
        intervals uses check-register-uses
    ] when
    cfg intervals assign-registers ;

: backtracking ( cfg -- )
    {
        number-instructions
        backtracking-allocate-and-assign
        resolve-data-flow
        check-numbering
    } apply-passes ;

SINGLETON: backtracking-allocator

M: backtracking-allocator allocate-cfg
    drop dup destruct-ssa backtracking ;

M: backtracking-allocator allocator-statistics
    drop H{ } clone
    backtracking-evictions get "evictions" pick set-at
    backtracking-splits get "splits" pick set-at
    assigned-bundles get length "assigned-bundles" pick set-at
    backtracking-loop-spills? get [
        loop-spill-site-count get "loop-spill-sites" pick set-at
        cold-spill-store-count get "redundant-loop-stores" pick set-at
    ] when ;
