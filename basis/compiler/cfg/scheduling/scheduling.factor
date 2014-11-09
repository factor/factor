! Copyright (C) 2009, 2010 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg.def-use compiler.cfg.dependence
compiler.cfg.instructions compiler.cfg.linear-scan.numbering compiler.cfg.rpo
cpu.architecture fry kernel make math namespaces sequences sets splitting ;
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

: score ( node -- n )
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

: split-insns ( insns -- pre/body/post )
    dup [ initial-insn-end ] [ final-insn-start ] bi 2array split-indices ;

: reorder-body ( body -- body' )
    [ <node> ] map
    [ build-dependence-graph ] [ build-fan-in-trees ] bi
    [ (reorder) ] V{ } make reverse ;

: reorder ( insns -- insns' )
    split-insns first3 [ reorder-body ] dip 3append ;

: schedule-block ( bb -- )
    [ reorder ] change-instructions drop ;

! TODO: stack effect should be ( cfg -- )
: schedule-instructions ( cfg --  cfg' )
    dup number-instructions
    dup reverse-post-order [ kill-block?>> not ] filter [ schedule-block ] each ;
