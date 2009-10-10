! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sets sequences
fry combinators.short-circuit locals make arrays
compiler.cfg
compiler.cfg.dominance
compiler.cfg.predecessors
compiler.cfg.loop-detection
compiler.cfg.rpo
compiler.cfg.instructions 
compiler.cfg.registers
compiler.cfg.dataflow-analysis 
compiler.cfg.utilities ;
IN: compiler.cfg.write-barrier

! Eliminate redundant write barrier hits.

! Objects which have already been marked, as well as
! freshly-allocated objects
SYMBOL: safe

! Objects which have been mutated
SYMBOL: mutated

GENERIC: eliminate-write-barrier ( insn -- ? )

M: ##allot eliminate-write-barrier
    dst>> safe get conjoin t ;

M: ##write-barrier eliminate-write-barrier
    src>> dup safe get key? not
    [ safe get conjoin t ] [ drop f ] if ;

M: insn eliminate-write-barrier drop t ;

! This doesn't actually benefit from being a dataflow analysis
! might as well be dominator-based
! Dealing with phi functions would help, though
FORWARD-ANALYSIS: safe

: has-allocation? ( bb -- ? )
    instructions>> [ { [ ##allocation? ] [ ##call? ] } 1|| ] any? ;

M: safe-analysis transfer-set
    drop [ H{ } assoc-clone-like safe set ] dip
    instructions>> [
        eliminate-write-barrier drop
    ] each safe get ;

M: safe-analysis join-sets
    drop has-allocation? [ drop H{ } clone ] [ assoc-refine ] if ;

: write-barriers-step ( bb -- )
    dup safe-in H{ } assoc-clone-like safe set
    instructions>> [ eliminate-write-barrier ] filter-here ;

GENERIC: remove-dead-barrier ( insn -- ? )

M: ##write-barrier remove-dead-barrier
    src>> mutated get key? ;

M: ##set-slot remove-dead-barrier
    obj>> mutated get conjoin t ;

M: ##set-slot-imm remove-dead-barrier
    obj>> mutated get conjoin t ;

M: insn remove-dead-barrier drop t ;

: remove-dead-barriers ( bb -- )
    H{ } clone mutated set
    instructions>> [ remove-dead-barrier ] filter-here ;

! Availability of slot
! Anticipation of this and set-slot would help too, maybe later
FORWARD-ANALYSIS: slot

UNION: access ##slot ##slot-imm ##set-slot ##set-slot-imm ;

M: slot-analysis transfer-set
    drop [ H{ } assoc-clone-like ] dip
    instructions>> over '[
        dup access? [
            obj>> _ conjoin
        ] [ drop ] if
    ] each ;

: slot-available? ( vreg bb -- ? )
    slot-in key? ;

: make-barriers ( vregs -- bb )
    [ [ next-vreg next-vreg ##write-barrier ] each ] V{ } make <simple-block> ;

: emit-barriers ( vregs loop -- )
    swap [
        [ [ header>> predecessors>> ] [ ends>> keys ] bi diff ]
        [ header>> ] bi
    ] [ make-barriers ] bi*
    insert-basic-block ;

: write-barriers ( bbs -- bb=>barriers )
    [
        dup instructions>>
        [ ##write-barrier? ] filter
        [ src>> ] map
    ] { } map>assoc
    [ nip empty? not ] assoc-filter ;

: filter-dominant ( bb=>barriers bbs -- barriers )
    '[ drop _ [ dominates? ] with all? ] assoc-filter
    values concat prune ;

: dominant-write-barriers ( loop -- vregs )
    [ blocks>> values write-barriers ] [ ends>> keys ] bi filter-dominant ;

: safe-loops ( -- loops )
    loops get values
    [ blocks>> keys [ has-allocation? not ] all? ] filter ;

:: insert-extra-barriers ( cfg -- )
    safe-loops [| loop |
        cfg needs-dominance needs-predecessors drop
        loop dominant-write-barriers
        loop header>> '[ _ slot-available? ] filter
        [ loop emit-barriers cfg cfg-changed drop ] unless-empty
    ] each ;

: contains-write-barrier? ( cfg -- ? )
    post-order [ instructions>> [ ##write-barrier? ] any? ] any? ;

: eliminate-write-barriers ( cfg -- cfg' )
    dup contains-write-barrier? [
        needs-loops
        dup [ remove-dead-barriers ] each-basic-block
        dup compute-slot-sets
        dup insert-extra-barriers
        dup compute-safe-sets
        dup [ write-barriers-step ] each-basic-block
    ] when ;
