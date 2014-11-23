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

: set-parent-indices ( node -- )
    children>> building get length
    '[ _ >>parent-index drop ] each ;

: ready? ( node -- ? ) precedes>> assoc-empty? ;

! Remove the node and unregister it from all nodes precedes links.
: remove-node ( nodes node -- )
    [ swap remove! ] keep '[ precedes>> _ swap delete-at ] each ;

: score ( node -- n )
    [ parent-index>> ] [ registers>> neg ] [ insn>> insn#>> ] tri 3array ;

: select-instruction ( nodes -- insn/f )
    [ f ] [
        ! select one among the ready nodes (roots)
        dup [ ready? ] filter [ score ] supremum-by
        [ remove-node ] keep
        [ insn>> ] [ set-parent-indices ] bi
    ] if-empty ;

: (reorder) ( nodes -- )
    dup select-instruction [ , (reorder) ] [ drop ] if* ;

UNION: initial-insn
    ##phi ##inc-d ##inc-r ##callback-inputs
    ! See #1187
    ##peek ;

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

: setup-nodes ( insns -- nodes )
    [ <node> ] V{ } map-as
    [ build-dependence-graph ] [ build-fan-in-trees ] [ ] tri ;

: reorder-body ( body -- body' )
    setup-nodes [ (reorder) ] V{ } make reverse ;

: reorder ( insns -- insns' )
    split-insns first3 [ reorder-body ] dip 3append ;

: schedule-block ( bb -- )
    [ reorder ] change-instructions drop ;

! TODO: stack effect should be ( cfg -- )
: schedule-instructions ( cfg --  cfg' )
    dup number-instructions
    dup reverse-post-order [ kill-block?>> not ] filter
    [ schedule-block ] each ;
