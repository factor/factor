! Copyright (C) 2009, 2010 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg.def-use compiler.cfg.dependence
compiler.cfg.instructions compiler.cfg.linear-scan.numbering compiler.cfg.rpo
cpu.architecture fry kernel make math namespaces sequences sets splitting ;
FROM: namespaces => set ;
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

: ready? ( node -- ? ) precedes>> assoc-empty? ;

: remove-node ( roots node -- )
    dup follows>> [ [ precedes>> check-delete-at ] with each ] keep
    [ ready? ] filter swap push-all ;

: score ( node -- n )
    [ parent-index>> ] [ registers>> neg ] [ insn>> insn#>> ] tri 3array ;

: select ( vector quot: ( elt -- score ) -- elt )
    dupd supremum-by swap dupd remove-eq! drop ; inline

: select-instruction ( roots -- insn/f )
    [ f ] [
        dup [ score ] select
        [ remove-node ] keep
        [ insn>> ] [ set-parent-indices ] bi
    ] if-empty ;

: (reorder) ( roots -- )
    dup select-instruction [ , (reorder) ] [ drop ] if* ;

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

: setup-root-nodes ( insns -- roots )
    [ <node> ] map
    [ build-dependence-graph ]
    [ build-fan-in-trees ]
    [ [ ready? ] V{ } filter-as ] tri ;

: reorder-body ( body -- body' )
    setup-root-nodes [ (reorder) ] V{ } make reverse ;

: reorder ( insns -- insns' )
    split-insns first3 [ reorder-body ] dip 3append ;

: schedule-block ( bb -- )
    [ reorder ] change-instructions drop ;

! TODO: stack effect should be ( cfg -- )
: schedule-instructions ( cfg --  cfg' )
    dup number-instructions
    dup reverse-post-order [ kill-block?>> not ] filter
    [ schedule-block ] each ;
