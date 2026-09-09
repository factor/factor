! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.linearization
compiler.cfg.linear-scan compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.ranges compiler.cfg.linear-scan.resolve
compiler.cfg.utilities compiler.cfg.register-allocation
compiler.cfg.ssa.destruction.leaders compiler.cfg.register-allocation.occupancy
compiler.cfg.register-allocation.ssa compiler.cfg.register-allocation.chordal.bases
compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.rematerialization
cpu.architecture heaps kernel locals make math
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
    backtracking-directed-splits backtracking-minimal-splits
    backtracking-point-blocks backtracking-block-starts backtracking-barriers
    backtracking-second-chance-attempts backtracking-second-chance-assignments
    backtracking-register-transitions backtracking-original-intervals
    backtracking-local-moves ;
SYMBOL: bundle-occupancy
SYMBOL: bundle-queue
SYMBOL: assigned-bundles
SYMBOL: backtracking-evictions
SYMBOL: backtracking-splits

: interval-size ( interval -- n )
    ranges>> [ first2 swap - 1 + ] map-sum ;

: minimal-interval? ( interval -- ? )
    dup uses>> empty? [ drop f ] [
        [ [ first-use n>> ] [ last-use n>> ] bi swap - 1 <= ]
        [ [ live-interval-start ] [ first-use n>> ] bi = ]
        [ [ live-interval-end ] [ last-use n>> 1 + ] bi <= ] tri and and
    ] if ;

:: <allocation-bundle> ( intervals -- bundle )
    intervals [ interval-size ] map-sum :> size
    intervals intervals length 1 =
    intervals [ minimal-interval? ] all? and [ 1/0. ] [
        intervals [ uses>> [ spill-site-weight ] map-sum ] map-sum size /
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

! Phi definitions have no physical instruction operand. A fragment whose
! only use is such a stack-capable definition belongs to the spill bundle;
! forcing all simultaneous phi results into registers is impossible.
: enqueue-bundle ( bundle -- )
    dup intervals>> [ uses>> [ spill-slot?>> ] all? ] all? [
        intervals>> [ ensure-interval-home ] each
    ] [ dup priority>> bundle-queue get heap-push ] if ;

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

:: bundle-split-sites ( bundle -- sites )
    bundle intervals>> [ uses>> [ n>> ] map ] map concat members natural-sort
    [ but-last ] [ rest ] bi zip [ first2 swap - 1 > ] filter [ second 1 - ] map ;

ERROR: unsatisfiable-register-pressure interval ;

! Each split reduces the number of uses in a bundle. Once only one use
! remains, trim away its live-through tails and connect them via a slot.
! Minimal intervals have infinite weight and can never evict each other.
:: split-single-interval ( interval -- )
    interval ensure-interval-home
    interval uses>> :> uses
    interval minimal-interval? [ interval unsatisfiable-register-pressure ] when
    backtracking-splits inc
    interval 1array <allocation-bundle> bundle-split-sites :> sites
    sites empty? [
        backtracking-minimal-splits inc
        interval spill-after spill-before enqueue-interval
    ] [
        sites dup length 2 /i swap nth interval swap split-for-spill
        [ enqueue-interval ] bi@
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
            conflict spill-site-weights get at 1 or :> move-cost
            split-option [
                move-cost split-option third <
                move-cost split-option third = conflict split-option second > and or
            ] [ t ] if [
                reg conflict move-cost 3array split-option!
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

! Gaps carry no mandatory operand. Give the whole canonical spill bundle
! one non-evicting allocation attempt after the main queue has converged.
TUPLE: backtracking-register-home reg ;

M: backtracking-register-home emit-save
    reg>> -rot ##copy, ;

M: backtracking-register-home emit-restore
    reg>> swap ##copy, ;

:: prepare-backtracking-points ( cfg -- )
    H{ } clone backtracking-point-blocks set
    H{ } clone backtracking-block-starts set
    V{ } clone backtracking-barriers set
    cfg linearization-order [| bb |
        bb bb block-from backtracking-point-blocks get set-at
        t bb block-from backtracking-block-starts get set-at
        bb instructions>> [| insn |
            bb insn insn#>> backtracking-point-blocks get set-at
            bb insn insn#>> 1 + backtracking-point-blocks get set-at
            insn clobber-insn? insn gc-map-insn? or [
                insn insn#>> dup 2array backtracking-barriers get push
            ] when
        ] each
    ] each ;

:: subtract-live-range ( range occupied -- remaining )
    range first :> start!
    range second :> end
    V{ } clone :> remaining
    occupied [| taken |
        taken first start > [
            start taken first 1 - end min 2array remaining push
        ] when
        taken second 1 + start max start!
    ] each
    start end <= [ start end 2array remaining push ] when
    remaining [ first2 <= ] filter ;

:: uncovered-ranges ( interval allocated -- ranges )
    allocated [ vreg>> interval vreg>> = ] filter
    [ ranges>> ] map concat backtracking-barriers get append
    [ first ] sort-by :> occupied
    interval ranges>> [| range |
        occupied [ range intersect-range ] filter
        range swap subtract-live-range
    ] map concat ;

:: gap-interval ( vreg range -- interval/f )
    range first :> start!
    ! Instruction positions are even; odd starts only represent block entry.
    start 2 mod 0 = start backtracking-block-starts get key? or
    [ ] [ start 1 + start! ] if
    start range second <= [
        vreg <live-interval>
        start range second 2array 1vector >>ranges
        vreg rep-of >>reload-rep
        vreg rep-of >>spill-rep
        range second dup backtracking-point-blocks get at block-to = [ ] [
            vreg dup rep-of assign-spill-slot >>spill-to
        ] if
        start backtracking-block-starts get key? [ ] [
            vreg dup rep-of assign-spill-slot >>reload-from
        ] if
    ] [ f ] if ;

:: second-chance-bundles ( allocated -- bundles )
    H{ } clone :> groups
    backtracking-original-intervals get [| interval |
        interval vreg>> rematerialization-of [ ] [
            interval allocated uncovered-ranges [| range |
                interval vreg>> range gap-interval [| gap |
                    gap interval vreg>> bundle-spillsets get at groups push-at
                ] when*
            ] each
        ] if
    ] each
    groups values [ <allocation-bundle> ] map ;

:: reify-register-transition ( before after -- )
    before live-interval-end 1 + :> boundary
    boundary after live-interval-start =
    boundary backtracking-block-starts get key? not and
    boundary backtracking-point-blocks get at
    boundary 1 - backtracking-point-blocks get at eq? and [
        ! The same original SSA value is resident across this contiguous
        ! within-block boundary. Edge entries are handled by SSA resolution.
        before f >>spill-to drop
        after before reg>> after reg>> = [ f ] [
            before reg>> backtracking-register-home boa
        ] if >>reload-from drop
        backtracking-register-transitions inc
    ] when ;

:: reify-register-transitions ( intervals -- )
    H{ } clone :> groups
    intervals [ dup vreg>> groups push-at ] each
    groups values [
        [ live-interval-start ] sort-by
        [ but-last ] [ rest ] bi [ reify-register-transition ] 2each
    ] each ;

! Splits can exchange two registers at one instruction boundary. Collect
! every reload at such a boundary and resolve them simultaneously; emitting
! register copies in heap order could overwrite another transition's source.
:: prepare-backtracking-moves ( intervals -- )
    H{ } clone :> points
    intervals [ reload-from>> backtracking-register-home? ] filter
    [ live-interval-start t swap points set-at ] each
    H{ } clone :> groups
    intervals [| interval |
        interval live-interval-start points key? interval reload-from>> >boolean and [
            interval interval live-interval-start groups push-at
        ] when
    ] each
    init-resolve
    groups [| intervals-at-point |
        [ intervals-at-point [| interval |
            interval reload-from>> dup backtracking-register-home? [ reg>> ] when
            interval reg>> interval reload-rep>> add-mapping
            interval f >>reload-from drop
        ] each ] { } make mapping-instructions but-last
    ] assoc-map backtracking-local-moves set ;

:: insert-backtracking-moves ( cfg -- )
    cfg [
        [ [ [
            dup insn#>> backtracking-local-moves get at [ % ] when* ,
        ] each ] V{ } make ] change-instructions drop
    ] each-basic-block ;

:: allocate-second-chance ( allocated -- intervals )
    backtracking-point-blocks get assoc-empty? [ allocated ] [
        allocated second-chance-bundles [| bundle |
            backtracking-second-chance-attempts inc
            bundle bundle-register-order [| reg |
                bundle reg bundle-conflicts empty? [
                    bundle reg assign-bundle
                    backtracking-second-chance-assignments inc t
                ] [ f ] if
            ] any? drop
        ] each
        assigned-bundles get [ intervals>> ] map concat dup reify-register-transitions
    ] if ;

:: backtracking-allocation ( intervals/syncs machine-regs -- intervals )
    intervals/syncs [ live-interval-state? ] filter [ clone ] map
    backtracking-original-intervals set
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
    0 backtracking-second-chance-attempts set
    0 backtracking-second-chance-assignments set
    0 backtracking-register-transitions set
    intervals/syncs [ live-interval-state? ] filter coalesce-bundle-groups :> groups
    groups initialize-spillsets
    intervals/syncs [ live-interval-state? not ] filter :> syncs
    groups [ syncs append prepare-bundles dup empty?
        [ drop ] [ <allocation-bundle> enqueue-bundle ] if
    ] each
    bundle-queue get [ drop process-bundle ] slurp-heap
    assigned-bundles get [ intervals>> ] map concat allocate-second-chance finish-loop-spills ;

:: prepare-backtracking-affinities ( cfg -- )
    V{ } clone :> affinities
    cfg cfg>insns [| insn |
        insn ##phi? [
            insn inputs>> values [ insn dst>> 2array affinities push ] each
        ] [
            insn ##copy? [ insn src>> insn dst>> 2array affinities push ] when
        ] if
    ] each
    affinities backtracking-affinities set ;

:: backtracking-allocation-with-registers ( cfg machine-regs -- )
    f leader-map set
    cfg construct-ssa-bases
    cfg compute-ssa-live-sets
    ! Keep original identities. A merged allocation bundle never aliases SSA
    ! values, including distinct incoming values of a phi.
    representations get keys [ dup ] H{ } map>assoc leader-map set
    cfg number-instructions
    cfg prepare-backtracking-affinities
    cfg prepare-backtracking-points
    backtracking-loop-spills? get :> cold-stores?
    t backtracking-loop-spills? set
    cfg prepare-spill-sites
    cold-stores? backtracking-loop-spills? set
    cfg compute-ssa-intervals :> input
    check-allocation? get [ input required-register-uses ] [ f ] if :> uses
    input machine-regs backtracking-allocation :> intervals
    check-allocation? get [
        intervals machine-regs check-allocated-intervals
        intervals uses check-register-uses
    ] when
    intervals prepare-backtracking-moves
    cfg intervals assign-ssa-registers
    cfg insert-backtracking-moves
    cfg resolve-ssa-data-flow
    cfg check-numbering ;

: backtracking ( cfg -- )
    dup admissible-registers backtracking-allocation-with-registers ;

SINGLETON: backtracking-allocator

M: backtracking-allocator allocate-cfg
    drop backtracking ;

M: backtracking-allocator allocator-statistics
    drop H{ } clone
    "ssa-bundle-backtracking" "algorithm" pick set-at
    0 "fallback-count" pick set-at
    backtracking-merges get "bundle-merges" pick set-at
    backtracking-shared-homes get "shared-spill-homes" pick set-at
    backtracking-directed-splits get "conflict-directed-splits" pick set-at
    backtracking-hint-hits get "register-hint-hits" pick set-at
    backtracking-minimal-splits get "minimal-splits" pick set-at
    backtracking-second-chance-attempts get "second-chance-attempts" pick set-at
    backtracking-second-chance-assignments get "second-chance-assignments" pick set-at
    backtracking-register-transitions get "register-transitions" pick set-at
    backtracking-evictions get "evictions" pick set-at
    backtracking-splits get "splits" pick set-at
    assigned-bundles get length "assigned-bundles" pick set-at
    backtracking-loop-spills? get [
        loop-spill-site-count get "loop-spill-sites" pick set-at
        cold-spill-store-count get "redundant-loop-stores" pick set-at
    ] when ;
