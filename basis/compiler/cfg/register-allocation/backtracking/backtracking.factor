! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.linearization
compiler.cfg.def-use compiler.cfg.liveness
compiler.cfg.linear-scan compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.ranges compiler.cfg.linear-scan.resolve
compiler.cfg.utilities compiler.cfg.register-allocation
compiler.cfg.ssa.destruction.leaders compiler.cfg.register-allocation.occupancy
compiler.cfg.register-allocation.ssa compiler.cfg.register-allocation.chordal.bases
compiler.cfg.register-allocation.ssa.phases compiler.cfg.rpo
compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.rematerialization
continuations cpu.architecture grouping heaps kernel locals make math
math.order namespaces sequences sorting vectors ;
FROM: sets => members ;
FROM: compiler.cfg.linear-scan.live-intervals => intervals-intersect? ;
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
    backtracking-register-transitions backtracking-interior-gaps-skipped backtracking-original-intervals
    backtracking-local-moves backtracking-phase-mode? backtracking-late-points
    backtracking-cluster-splits backtracking-split-budget-exhaustions
    backtracking-edge-entry-reloads ;
SYMBOL: bundle-occupancy
SYMBOL: bundle-queue
SYMBOL: assigned-bundles
SYMBOL: backtracking-evictions
SYMBOL: backtracking-splits

: interval-size ( interval -- n )
    ranges>> [ first2 swap - 1 + ] map-sum ;

:: phase-reload-start ( use -- n )
    use n>> :> n
    backtracking-phase-mode? get use use-rep>> >boolean and
    n backtracking-late-points get key? and [ n 1 - ] [ n ] if ;

:: minimal-interval? ( interval -- ? )
    interval uses>> empty? [ f ] [
        interval first-use n>> :> first
        interval last-use n>> :> last
        backtracking-phase-mode? get [ first 2 /i last 2 /i = ] [ first last = ] if
        interval live-interval-start interval first-use phase-reload-start = and
        interval live-interval-end last 1 + <= and
    ] if ;

:: normalize-phase-reload ( interval -- interval/f )
    interval [
        backtracking-phase-mode? get interval reload-from>> >boolean and [
            interval first-use phase-reload-start :> start
            interval [ start swap fix-lower-bound ] change-ranges drop
        ] when
    ] when
    interval ;

:: phase-spill-before ( interval -- interval/f )
    interval uses>> empty? [ f ] [
        interval last-use n>> :> last
        ! Cap at this live range, not the interval's final endpoint. A later
        ! range may follow a hole occupied by an affinity-bundled result.
        interval ranges>> [ last swap first2 between? ] find nip second :> end
        interval spill-before
        backtracking-phase-mode? get [
            last dup 2 mod zero? [ 1 + ] when end min
            swap [ fix-upper-bound ] change-ranges
        ] when
    ] if ;

! Phase splits retain the last point of the prefix. Unlike sync splitting,
! no operand at this boundary may be discarded: a late use can immediately
! precede the next instruction's early use without an unused integer point.
:: split-for-bundle ( interval position -- before after )
    backtracking-phase-mode? get [
        interval clone f >>spill-to :> before
        interval clone f >>reg f >>reload-from :> after
        interval uses>> [ n>> position <= ] partition
        before after [ uses<< ] bi-curry@ bi*
        interval ranges>> position split-ranges
        before after [ ranges<< ] bi-curry@ bi*
        before phase-spill-before
        after spill-after normalize-phase-reload
    ] [ interval position split-for-spill ] if ;

ERROR: overlapping-backtracking-bundle intervals ;

:: check-backtracking-bundle ( bundle -- )
    check-allocation? get [
        bundle ranges>> [ [ second ] [ first ] bi* < ] monotonic?
        [ ] [ bundle intervals>> overlapping-backtracking-bundle ] if
    ] when ;

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
    intervals first vreg>> bundle-spillsets get at allocation-bundle boa
    dup check-backtracking-bundle ;

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
    [ but-last ] [ rest ] bi zip
    backtracking-phase-mode? get [
        [| pair |
            pair second dup backtracking-late-points get key? [ 1 - ] when
            1 - :> position
            pair first position <= [ position ] [ f ] if
        ] map sift members
    ] [ [ first2 swap - 1 > ] filter [ second 1 - ] map ] if ;

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
        interval spill-after normalize-phase-reload phase-spill-before enqueue-interval
    ] [
        sites dup length 2 /i swap nth interval swap split-for-bundle
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

:: bundle-site-weights ( bundle position -- before after )
    bundle intervals>> [ uses>> ] map concat [ n>> ] sort-by
    [ n>> position <= ] partition
    [ last spill-site-weight ] [ first spill-site-weight ] bi* ;

:: conflict-split-site ( bundle conflict -- site/f )
    bundle bundle-split-sites :> sites
    sites empty? [ f ] [
        sites [ conflict < ] filter :> prefix-sites
        prefix-sites empty? [ sites first ] [
            prefix-sites last :> best!
            bundle best bundle-site-weights + :> cost!
            ! Preserve the obstruction-free prefix, but cut at a cooler
            ! loop-depth transition if it avoids transport in a hot cluster.
            prefix-sites [| site |
                bundle site bundle-site-weights :> ( before after )
                before after + :> candidate
                before after = not candidate cost < and [
                    site best! candidate cost!
                ] when
            ] each
            best prefix-sites last = [ ] [ backtracking-cluster-splits inc ] if
            best
        ] if
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
        interval live-interval-end position
        backtracking-phase-mode? get [ <= ] [ < ] if [ interval before push ] [
            interval live-interval-start position > [ interval after push ] [
                interval ensure-interval-home
                interval position split-for-bundle
                [ after push ] when* [ before push ] when*
            ] if
        ] if
    ] each
    before enqueue-pieces after enqueue-pieces ;

CONSTANT: backtracking-max-splits 16

! Repeated one-use peeling is finite but can still scan a long use vector
! quadratically. Bound that work per original spillset, then partition all
! remaining operands directly into minimal instruction-sized fragments.
:: split-bundle-minimally ( bundle -- )
    backtracking-splits inc
    backtracking-split-budget-exhaustions inc
    bundle intervals>> [| interval |
        interval ensure-interval-home
        H{ } clone :> clusters
        interval uses>> [| use |
            use use n>> backtracking-phase-mode? get [ 2 /i ] when clusters push-at
        ] each
        clusters values [ [ n>> ] sort-by ] map [ first n>> ] sort-by [| uses |
            interval clone uses >vector >>uses f >>reload-from f >>spill-to
            spill-after normalize-phase-reload phase-spill-before enqueue-interval
            backtracking-minimal-splits inc
        ] each
    ] each ;

: split-budget-exhausted? ( bundle -- ? )
    spillset>> [ splits>> backtracking-max-splits >= ] [ f ] if* ;

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
            conflict spill-site-weights get at 1 or cost + :> move-cost
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
            bundle split-budget-exhausted? [ bundle split-bundle-minimally ] [
                bundle split-option second conflict-split-site [| site |
                    bundle spillset>> [ split-option first >>hint drop ] when*
                    bundle site split-bundle-at
                ] [ bundle split-bundle ] if*
            ] if
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
            interval sync n>> split-interval
            [ phase-spill-before ] [ spill-after normalize-phase-reload ] bi* 2array sift
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
    H{ } clone backtracking-late-points set
    H{ } clone backtracking-point-blocks set
    H{ } clone backtracking-block-starts set
    V{ } clone backtracking-barriers set
    cfg linearization-order [| bb |
        bb backtracking-phase-mode? get [ phase-block-from ] [ block-from ] if :> entry
        bb entry backtracking-point-blocks get set-at
        t entry backtracking-block-starts get set-at
        ! Physical SSA assignment skips complete Factor call/prologue/epilogue
        ! blocks. A second-chance range must neither cross their clobbers nor
        ! start inside them and strand the assignment heap.
        bb kill-block?>> [
            entry bb block-to backtracking-phase-mode? get [ 1 + ] when
            2array backtracking-barriers get push
        ] when
        bb instructions>> [| insn |
            insn phase-split-insn? [
                t insn insn#>> 1 + backtracking-late-points get set-at
            ] when
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

:: uncovered-vreg-ranges ( interval fragments -- ranges )
    ! The overwhelmingly common unsplit interval has no spill bundle. Avoid
    ! rescanning every clobber and sorting an unchanged full range set.
    fragments length 1 = [
        fragments first ranges>> interval ranges>> =
    ] [ f ] if [ { } ] [
        fragments [ ranges>> ] map concat backtracking-barriers get append
        [ first ] sort-by :> occupied
        interval ranges>> [| range |
            occupied [ range intersect-range ] filter
            range swap subtract-live-range
        ] map concat
    ] if ;

:: uncovered-ranges ( interval allocated -- ranges )
    interval allocated [ vreg>> interval vreg>> = ] filter
    uncovered-vreg-ranges ;

:: gap-start ( range -- start )
    range first :> start
    ! Instruction positions are even; odd starts only represent block entry.
    start 2 mod 0 = start backtracking-block-starts get key? or
    [ start ] [ start 1 + ] if ;

:: productive-gap? ( range fragments -- ? )
    range gap-start :> start
    range second :> end
    start end > [ t ] [
        start backtracking-point-blocks get at :> bb
        start bb backtracking-phase-mode? get [ phase-block-from ] [ block-from ] if >
        bb end backtracking-point-blocks get at eq? and
        end bb block-to backtracking-phase-mode? get [ 1 + ] when < and [
            ! Strictly interior ranges cross no CFG edge. Unless both sides
            ! touch existing register fragments of this original value, residency
            ! saves no memory operation: it merely moves a store or reload and
            ! can add a register copy. Keep every entry/exit and multiblock gap;
            ! those can bridge useful nonadjacent CFG edges (including GC fast paths).
            fragments [ live-interval-end 1 + start = ] any?
            fragments [ live-interval-start end 1 + = ] any? and
        ] [ t ] if
    ] if ;

:: gap-interval ( vreg range -- interval/f )
    range gap-start :> start
    start range second <= [
        vreg <live-interval>
        start range second 2array 1vector >>ranges
        vreg rep-of >>reload-rep
        vreg rep-of >>spill-rep
        range second dup backtracking-point-blocks get at block-to
        backtracking-phase-mode? get [ 1 + ] when = [ ] [
            vreg dup rep-of assign-spill-slot >>spill-to
        ] if
        start backtracking-block-starts get key?
        start backtracking-point-blocks get at predecessors>>
        [ kill-block?>> ] any? not and [ ] [
            ! Kill-block outgoing edges have no physical register map. The
            ! resident version must start with an explicit memory reload in
            ! the ordinary successor, even at its first instruction. Entry
            ! recording publishes this home, so ordinary predecessors of a
            ! mixed join also initialize it through normal edge resolution.
            vreg dup rep-of assign-spill-slot >>reload-from
        ] if
    ] [ f ] if ;

:: second-chance-bundles ( allocated -- bundles )
    H{ } clone :> groups
    H{ } clone :> by-vreg
    allocated [ dup vreg>> by-vreg push-at ] each
    backtracking-original-intervals get [| interval |
        interval vreg>> rematerialization-of [ ] [
            interval vreg>> by-vreg at :> fragments
            interval fragments uncovered-vreg-ranges [| range |
                range fragments productive-gap? [
                    interval vreg>> range gap-interval [| gap |
                        gap interval vreg>> bundle-spillsets get at groups push-at
                    ] when*
                ] [ backtracking-interior-gaps-skipped inc ] if
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
    0 backtracking-cluster-splits set
    0 backtracking-minimal-splits set
    0 backtracking-split-budget-exhaustions set
    0 backtracking-second-chance-attempts set
    0 backtracking-second-chance-assignments set
    0 backtracking-register-transitions set
    0 backtracking-edge-entry-reloads set
    0 backtracking-interior-gaps-skipped set
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
            ! Factor's two-operand emitters can reuse the first input. The
            ! phase ranges prove whether it dies before the result; other
            ! inputs and def-is-use instructions remain interfering.
            insn uses-vregs :> inputs
            insn defs-vregs :> outputs
            inputs empty? not outputs length 1 = and [
                inputs first outputs first 2array affinities push
            ] when
        ] if
    ] each
    affinities backtracking-affinities set ;

: prepare-backtracking-phase-weights ( -- )
    spill-site-weights get >alist [
        first2 swap 1 + spill-site-weights get set-at
    ] each
    cold-definition-sites get keys [
        1 + t swap cold-definition-sites get set-at
    ] each ;

ERROR: unconsumed-backtracking-moves mappings ;

:: edge-entry-reload? ( interval -- ? )
    interval live-interval-start :> start
    interval reload-from>> spill-slot?
    start backtracking-block-starts get key? and [
        start backtracking-point-blocks get at :> bb
        bb predecessors>> :> predecessors
        bb kill-block?>> not predecessors empty? not and
        predecessors [ kill-block?>> ] any? not and
        bb instructions>> first :> first-insn
        first-insn clobber-insn? first-insn gc-map-insn? or
        first-insn ##phi? or not and
        interval vreg>> bb live-in key? and
    ] [ f ] if ;

:: entry-transport-records ( intervals -- records )
    intervals [ edge-entry-reload? ] filter
    [ f ] IH{ } map>assoc ;

ERROR: invalid-recorded-entry-reload interval instructions incoming ;

:: check-recorded-entry-reload ( interval instructions incoming -- )
    instructions length 1 = [
        instructions first :> insn
        insn ##reload? [
            insn src>> interval reload-from>> =
            insn dst>> interval reg>> = and
            insn rep>> interval reload-rep>> = and
            interval vreg>> incoming at interval reload-from>> = and
        ] [ f ] if
    ] [ f ] if
    [ ] [ interval instructions incoming invalid-recorded-entry-reload ] if ;

:: common-entry-home? ( interval bb -- ? )
    bb predecessors>> [| predecessor |
        interval vreg>> predecessor machine-live-out at
        interval reload-from>> =
    ] all? ;

:: reify-entry-transports ( records -- )
    ! Decide from the actual post-assignment edge maps. When every incoming
    ! value already occupies the reload home, keep one shared successor load
    ! rather than duplicating it onto edges. Mixed locations still benefit
    ! from direct parallel edge transport instead of a memory round trip.
    0 backtracking-edge-entry-reloads set
    records [| interval instructions |
        interval live-interval-start backtracking-point-blocks get at :> bb
        bb machine-live-in :> incoming
        interval instructions incoming check-recorded-entry-reload
        interval bb common-entry-home? [ ] [
            bb [ [| insn | instructions [ insn eq? ] any? not ] filter ]
                change-instructions drop
            interval reg>> interval vreg>> incoming set-at
            interval f >>reload-from drop
            backtracking-edge-entry-reloads inc
        ] if
    ] assoc-each ;

:: assign-backtracking-registers ( cfg intervals -- )
    ! Assignment publishes phi/edge locations in this namespace. A dynamic
    ! with-variable scope here would discard those results before resolution.
    phase-insn-prefixes get :> previous
    backtracking-local-moves get clone phase-insn-prefixes set
    [
        intervals entry-transport-records :> records
        cfg intervals f records assign-phase-ssa-registers-recording
        records reify-entry-transports
        phase-insn-prefixes get dup assoc-empty?
        [ drop ] [ unconsumed-backtracking-moves ] if
    ] [ previous phase-insn-prefixes set ] finally ;

:: backtracking-allocation-with-registers ( cfg machine-regs -- )
    t backtracking-phase-mode? set
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
    prepare-backtracking-phase-weights
    cold-stores? backtracking-loop-spills? set
    cfg compute-phase-ssa-intervals :> input
    check-allocation? get [ input required-register-uses ] [ f ] if :> uses
    input machine-regs backtracking-allocation :> intervals
    check-allocation? get [
        intervals machine-regs check-allocated-intervals
        intervals uses check-register-uses
    ] when
    cfg intervals check-phase-ssa-transports
    intervals prepare-backtracking-moves
    cfg intervals assign-backtracking-registers
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
    backtracking-cluster-splits get "loop-cluster-splits" pick set-at
    backtracking-hint-hits get "register-hint-hits" pick set-at
    backtracking-minimal-splits get "minimal-splits" pick set-at
    backtracking-split-budget-exhaustions get "split-budget-exhaustions" pick set-at
    backtracking-second-chance-attempts get "second-chance-attempts" pick set-at
    backtracking-second-chance-assignments get "second-chance-assignments" pick set-at
    backtracking-register-transitions get "register-transitions" pick set-at
    backtracking-edge-entry-reloads get "edge-entry-reloads" pick set-at
    backtracking-interior-gaps-skipped get "interior-gaps-skipped" pick set-at
    backtracking-evictions get "evictions" pick set-at
    backtracking-splits get "splits" pick set-at
    assigned-bundles get length "assigned-bundles" pick set-at
    backtracking-loop-spills? get [
        loop-spill-site-count get "loop-spill-sites" pick set-at
        cold-spill-store-count get "redundant-loop-stores" pick set-at
    ] when ;
