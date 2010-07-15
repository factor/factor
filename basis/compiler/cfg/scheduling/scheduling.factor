! Copyright (C) 2009, 2010 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry kernel locals make math
namespaces sequences sets combinators.short-circuit
compiler.cfg.def-use compiler.cfg.dependence
compiler.cfg.instructions compiler.cfg.liveness compiler.cfg.rpo
cpu.architecture ;
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
conditional-branch-insn
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

ERROR: not-all-instructions-were-scheduled old-bb new-bb ;

SYMBOL: check-scheduling?
f check-scheduling? set-global

:: check-instructions ( new-bb old-bb -- )
    new-bb old-bb [ instructions>> ] bi@
    [ [ length ] bi@ = ] [ [ unique ] bi@ = ] 2bi and
    [ old-bb new-bb not-all-instructions-were-scheduled ] unless ;

ERROR: definition-after-usage vregs old-bb new-bb ;

:: check-usages ( new-bb old-bb -- )
    HS{ } clone :> useds
    new-bb instructions>> split-3-ways drop nip
    [| insn |
        insn uses-vregs [ useds adjoin ] each
        insn defs-vregs :> defs-vregs
        defs-vregs useds intersects?
        [ defs-vregs old-bb new-bb definition-after-usage ] when
    ] each ;

: check-scheduling ( new-bb old-bb -- )
    [ check-instructions ] [ check-usages ] 2bi ;

: with-scheduling-check ( bb quot: ( bb -- ) -- )
    check-scheduling? get [
        over dup clone
        [ call( bb -- ) ] 2dip
        check-scheduling
    ] [
        call( bb -- )
    ] if ; inline

: number-insns ( insns -- )
    [ >>insn# drop ] each-index ;

: clear-numbers ( insns -- )
    [ f >>insn# drop ] each ;

: schedule-block ( bb -- )
    [
        [
            [ number-insns ]
            [ reorder ]
            [ clear-numbers ] tri
        ] change-instructions drop
    ] with-scheduling-check ;

! Really, instruction scheduling should be aware that there are
! multiple types of registers, but this number is just used
! to decide whether to schedule instructions
: num-registers ( -- x ) int-regs machine-registers at length ;

: might-spill? ( bb -- ? )
    [ live-in assoc-size ]
    [ instructions>> [ defs-vregs length ] map-sum ] bi
    + num-registers >= ;

: schedule-instructions ( cfg -- cfg' )
    dup [
        dup { [ kill-block?>> not ] [ might-spill? ] } 1&&
        [ schedule-block ] [ drop ] if
    ] each-basic-block ;
