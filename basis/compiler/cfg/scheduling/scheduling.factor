! Copyright (C) 2009, 2010 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry kernel locals make math
namespaces sequences sets combinators.short-circuit
compiler.cfg.def-use compiler.cfg.dependence
compiler.cfg.instructions compiler.cfg.rpo cpu.architecture ;
IN: compiler.cfg.scheduling

! Instruction scheduling to reduce register pressure, from:
! "Register-sensitive selection, duplication, and
!  sequencing of instructions"
! by Vivek Sarkar, et al.
! http://portal.acm.org/citation.cfm?id=377849

ERROR: bad-delete-at key assoc ;

: check-delete-at ( key assoc -- )
    2dup key? [ delete-at ] [ bad-delete-at ] if ;

: set-parent-indices ( node -- )
    children>> building get length
    '[ _ >>parent-index drop ] each ;

: remove-node ( node -- )
    [ follows>> members ] keep
    '[ [ precedes>> _ swap check-delete-at ] each ]
    [ [ ready? ] filter roots get push-all ] bi ;

: score ( insn -- n )
    [ parent-index>> ] [ registers>> neg ] [ insn>> insn#>> ] tri 3array ;

: pull-out-nth ( n seq -- elt )
    [ nth ] [ remove-nth! drop ] 2bi ;

: select ( vector quot -- elt )
    ! This could be sped up by a constant factor
    [ dup <enum> ] dip '[ _ call( insn -- score ) ] assoc-map
    dup values supremum '[ nip _ = ] assoc-find
    2drop swap pull-out-nth ; inline

: select-instruction ( -- insn/f )
    roots get [ f ] [
        [ score ] select 
        [ insn>> ]
        [ set-parent-indices ]
        [ remove-node ] tri
    ] if-empty ;

: (reorder) ( -- )
    select-instruction [
        , (reorder)
    ] when* ;

UNION: initial-insn ##phi ##inc-d ##inc-r ##callback-inputs ;

UNION: final-insn
##branch
##dispatch
conditional-branch-insn
##safepoint
##epilogue ##return
##callback-outputs ;

: initial-insn-end ( insns -- n )
    [ initial-insn? not ] find drop 0 or ;

: final-insn-start ( insns -- n )
    [ final-insn? not ] find-last drop [ 1 + ] [ 0 ] if* ;

:: split-3-ways ( insns -- first middle last )
    insns initial-insn-end :> a
    insns final-insn-start :> b
    insns a head-slice
    a b insns <slice>
    insns b tail-slice ;

: reorder ( insns -- insns' )
    split-3-ways [
        build-dependence-graph
        build-fan-in-trees
        [ (reorder) ] V{ } make reverse
    ] dip 3append ;

: number-insns ( insns -- )
    [ >>insn# drop ] each-index ;

: clear-numbers ( insns -- )
    [ f >>insn# drop ] each ;

: schedule-block ( bb -- )
    [
        [ number-insns ]
        [ reorder ]
        [ clear-numbers ] tri
    ] change-instructions drop ;

: schedule-instructions ( cfg -- cfg' )
    dup [
        dup kill-block?>> [ drop ] [ schedule-block ] if
    ] each-basic-block ;
