! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.validation compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities cpu.architecture
hashtables heaps kernel layouts locals make math namespaces prettyprint sequences
sorting vectors ;
FROM: sets => members ;
IN: compiler.cfg.register-allocation.backtracking.evidence

:: evidence-interval ( vreg positions -- interval )
    vreg <live-interval>
    positions first positions last 2array 1vector >>ranges
    positions [ <vreg-use> int-rep >>use-rep ] map >vector >>uses ;

: evidence-bank ( -- bank )
    f backtracking-phase-mode? set
    f backtracking-point-blocks set
    f backtracking-affinities set
    f f <basic-block> <cfg> cfg set
    H{ } clone representations set
    10 <iota> [ int-rep swap set-rep-of ] each
    int-regs machine-registers at first 1array int-regs swap 2array 1array ;

:: original-member ( vreg -- object )
    backtracking-original-intervals get [ vreg>> vreg = ] filter
    [ ranges>> ] map concat :> ranges
    vreg rep-of unparse :> representation
    H{ { "ssa_value" vreg } { "ranges" ranges }
       { "representation" representation } } ;

:: bundle-evidence ( -- witnesses )
    init-validation-representations
    [
        ##prologue, 1 D: 0 ##peek,
        2 1 int-rep ##copy, 3 2 int-rep ##copy,
        4 3 1 tag-fixnum ##add-imm,
        4 D: 0 ##replace, ##epilogue, ##return,
    ] V{ } make insns>cfg backtracking-allocator compile-validation-cfg :> word
    10 word execute( x -- y ) 11 assert=
    bundle-spillsets get values members [ members>> length 1 > ] filter [| spillset |
        spillset rep>> unparse :> representation
        spillset ranges>> :> ranges
        spillset members>> [ original-member ] map :> members
        H{ { "kind" "bundle" } { "representation" representation }
           { "bundle_ranges" ranges } { "members" members } }
    ] map ;

:: spillset-evidence ( -- witness )
    evidence-bank :> bank
    1 { 0 100 } evidence-interval
    2 { 20 22 24 40 } evidence-interval
    3 { 200 300 } evidence-interval
    4 { 220 222 224 240 } evidence-interval 4array bank backtracking-allocation :> allocated
    allocated bank check-allocated-intervals
    bundle-spillsets get values members [ home>> ] filter [| spillset |
        allocated [ vreg>> spillset members>> member? ] filter [| interval |
            interval vreg>> :> value
            value spillset rep>> lookup-spill-slot n>> :> slot
            interval ranges>> :> ranges
            H{ { "ssa_value" value } { "slot" slot } { "ranges" ranges } }
        ] map :> children
        spillset ranges>> :> ranges
        spillset home>> n>> :> slot
        spillset rep>> unparse :> representation
        H{ { "ranges" ranges } { "slot" slot }
           { "representation" representation } { "children" children } }
    ] map :> spillsets
    H{ { "kind" "spillsets" } { "spillsets" spillsets } } ;

:: owner-evidence ( bundle -- object )
    bundle intervals>> first vreg>> :> id
    bundle ranges>> :> ranges
    bundle weight>> >float :> weight
    H{ { "id" id } { "ranges" ranges } { "weight" weight } } ;

:: eviction-evidence ( -- witness )
    evidence-bank :> bank
    1 { 0 100 } evidence-interval 1array bank backtracking-allocation drop
    assigned-bundles get [ owner-evidence ] map :> before
    2 { 20 22 24 40 } evidence-interval 1array <allocation-bundle> :> request
    bank first second first :> register
    request register bundle-conflicts :> conflicts
    conflicts [ intervals>> first vreg>> ] map :> evicted
    request register conflicts conflicts conflict-cost 3array assign-with-eviction
    assigned-bundles get [ owner-evidence ] map :> after
    bundle-queue get heap-members [ intervals>> first vreg>> ] map :> requeued
    request ranges>> :> ranges
    request weight>> >float :> weight
    H{ { "kind" "eviction" } { "request_id" 2 }
       { "request_ranges" ranges } { "request_weight" weight }
       { "strict_weight" t } { "before" before } { "after" after }
       { "evicted" evicted } { "requeued" requeued } } ;

:: split-child ( id interval -- object )
    interval ranges>> :> ranges
    interval uses>> [ n>> ] map :> uses
    H{ { "id" id } { "ranges" ranges } { "uses" uses } } ;

:: split-evidence ( -- witness )
    evidence-bank drop
    H{ } clone spill-slots set
    f backtracking-barriers set
    1 { 0 20 40 100 } evidence-interval :> parent
    parent 39 split-for-bundle :> ( before after )
    before after 2array :> pieces
    parent pieces uncovered-ranges :> gaps
    H{ { "id" "canonical-spill-bundle" } { "ranges" gaps } { "uses" { } } } :> spill
    "before" before split-child "after" after split-child spill 3array :> children
    parent ranges>> :> ranges
    parent uses>> [ n>> ] map :> uses
    H{ { "kind" "split" } { "parent_ranges" ranges }
       { "parent_uses" uses } { "children" children } } ;

: backtracking-evidence ( -- document )
    [
        bundle-evidence
        spillset-evidence suffix
        eviction-evidence suffix
        split-evidence suffix
        "witnesses" associate
    ] with-scope ;
