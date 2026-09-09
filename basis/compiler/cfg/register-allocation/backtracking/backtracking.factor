! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.linear-scan compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.ranges compiler.cfg.linear-scan.resolve
compiler.cfg.utilities compiler.cfg.register-allocation
compiler.cfg.ssa.destruction compiler.cfg.register-allocation.occupancy
compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.rematerialization
cpu.architecture heaps kernel locals math
math.order namespaces sequences sorting vectors ;
FROM: sets => members ;
IN: compiler.cfg.register-allocation.backtracking

! An interval is a bundle of disjoint ranges already coalesced by SSA
! destruction. Unlike linear scan, the queue is ordered by size, and a
! later request can revoke an earlier assignment anywhere in the CFG.
TUPLE: allocation-bundle intervals weight priority ranges reg-class spillset ;
! Membership records storage affinity, never equivalence of SSA values.
TUPLE: allocation-spillset members ranges rep hint splits home ;
TUPLE: allocation-spill-home slot rep occupancy ;
SYMBOLS: bundle-spillsets spill-home-pool backtracking-affinities
    backtracking-merges backtracking-shared-homes backtracking-hint-hits
    backtracking-directed-splits backtracking-minimal-splits ;
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
        intervals [ ranges>> ] map concat [ first ] sort-by
    ] if
    intervals first interval-reg-class
    intervals first vreg>> bundle-spillsets get at allocation-bundle boa ;

:: make-spillset ( intervals -- spillset )
    intervals [ vreg>> ] map members
    intervals [ ranges>> ] map concat [ first ] sort-by
    intervals first vreg>> rep-of f 0 f allocation-spillset boa ;

:: ensure-spillset-home ( spillset -- )
    spillset home>> [ ] [
        spill-home-pool get [| home |
            home rep>> spillset rep>> =
            spillset ranges>> home occupancy>> occupancy-conflicts empty? and
        ] find nip :> reusable
        reusable [
            backtracking-shared-homes inc
            reusable
        ] [
            spillset members>> first spillset rep>> assign-spill-slot
            spillset rep>> <register-occupancy> allocation-spill-home boa
            dup spill-home-pool get push
        ] if :> home
        spillset spillset ranges>> home occupancy>> occupy-ranges
        spillset home slot>> >>home drop
        spillset members>> [| vreg |
            home slot>> vreg spillset rep>> rep-size 2array spill-slots get set-at
        ] each
    ] if ;

: ensure-interval-home ( interval -- )
    vreg>> dup rematerialization-of [ drop ] [
        bundle-spillsets get at [ ensure-spillset-home ] when*
    ] if ;

:: mergeable-groups? ( first-group second-group -- ? )
    first-group first vreg>> rep-of second-group first vreg>> rep-of =
    first-group second-group append [ vreg>> rematerialization-of ] any? not and
    first-group [| first-interval |
        second-group [ first-interval intervals-intersect? ] any?
    ] any? not and ;

! Phi affinities request a common location across an edge, not common bits
! across the whole CFG. Merge only complete nonoverlapping original ranges.
:: coalesce-bundle-groups ( intervals -- groups )
    H{ } clone :> groups
    intervals [ dup vreg>> groups push-at ] each
    backtracking-affinities get [| pair |
        pair first groups at :> first-group
        pair second groups at :> second-group
        first-group second-group and [
            first-group second-group eq? [ ] [
                first-group second-group mergeable-groups? [
                    first-group second-group append :> merged
                    merged [ vreg>> merged swap groups set-at ] each
                    backtracking-merges inc
                ] when
            ] if
        ] when
    ] each
    groups values members ;

:: initialize-spillsets ( groups -- )
    H{ } clone bundle-spillsets set
    V{ } clone spill-home-pool set
    groups [| intervals |
        intervals make-spillset :> spillset
        spillset members>> [ spillset swap bundle-spillsets get set-at ] each
    ] each ;

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
    bundle spillset>> [| spillset |
        spillset hint>> reg = [ backtracking-hint-hits inc ] when
        spillset reg >>hint drop
    ] when*
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
    interval ensure-interval-home
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

:: bundle-register-order ( bundle -- registers )
    bundle bundle-reg-class registers get at :> available
    bundle spillset>> [ hint>> ] [ f ] if* :> hint
    hint available member? [ hint available remove hint prefix ] [ available ] if ;

:: first-bundle-conflict ( bundle conflicts -- position )
    conflicts [ bundle ranges>> swap ranges>> intersect-ranges ] map sift infimum ;

:: bundle-split-sites ( bundle -- sites )
    bundle intervals>> [ uses>> [ n>> ] map ] map concat members natural-sort
    [ but-last ] [ rest ] bi zip [ first2 swap - 1 > ] filter [ second 1 - ] map ;

:: conflict-split-site ( bundle conflict -- site/f )
    bundle bundle-split-sites :> sites
    sites empty? [ f ] [
        sites [ conflict < ] filter dup empty?
        [ drop sites first ] [ last ] if
    ] if ;

: enqueue-pieces ( intervals -- )
    dup empty? [ drop ] [ <allocation-bundle> enqueue-bundle ] if ;

! Unlike unbundling each vreg, a split retains all compatible ranges on
! each side as one atomic allocation request. Both children carry the same
! spillset; no new value equivalence or storage identity is invented.
:: split-bundle-at ( bundle position -- )
    V{ } clone :> before
    V{ } clone :> after
    backtracking-splits inc
    backtracking-directed-splits inc
    bundle spillset>> [ [ 1 + ] change-splits drop ] when*
    bundle intervals>> [| interval |
        interval live-interval-end position < [ interval before push ] [
            interval live-interval-start position > [ interval after push ] [
                interval ensure-interval-home
                interval position split-for-spill
                [ after push ] when* [ before push ] when*
            ] if
        ] if
    ] each
    before enqueue-pieces after enqueue-pieces ;

:: process-bundle ( bundle -- )
    f :> cheapest!
    f :> split-option!
    bundle bundle-register-order [| reg |
        bundle reg bundle-conflicts :> conflicts
        conflicts empty? [
            bundle reg assign-bundle t
        ] [
            conflicts conflict-cost :> cost
            bundle conflicts first-bundle-conflict :> conflict
            split-option [ conflict split-option second > ] [ t ] if [
                reg conflict 2array split-option!
            ] when
            cheapest [ cost cheapest third < ] [ t ] if [
                reg conflicts cost 3array cheapest!
            ] when f
        ] if
    ] any? [
        cheapest third bundle weight>> < [
            bundle cheapest assign-with-eviction
        ] [
            bundle split-option second conflict-split-site [| site |
                bundle spillset>> [ split-option first >>hint drop ] when*
                bundle site split-bundle-at
            ] [ bundle split-bundle ] if*
        ] if
    ] unless ;

! Calls have stack operands in Factor's lowered IR. Materialize slots for
! the operands removed at a sync point, including an atomic stack result.
:: sync-operand-slots ( interval sync -- )
    interval ensure-interval-home
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
    0 backtracking-merges set
    0 backtracking-shared-homes set
    0 backtracking-hint-hits set
    0 backtracking-directed-splits set
    0 backtracking-minimal-splits set
    intervals/syncs [ live-interval-state? ] filter coalesce-bundle-groups :> groups
    groups initialize-spillsets
    intervals/syncs [ live-interval-state? not ] filter :> syncs
    groups [ syncs append prepare-bundles dup empty?
        [ drop ] [ <allocation-bundle> enqueue-bundle ] if
    ] each
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
