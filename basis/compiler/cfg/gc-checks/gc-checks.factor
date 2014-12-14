! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.predecessors
compiler.cfg.registers compiler.cfg.rpo compiler.cfg.utilities
cpu.architecture grouping kernel layouts locals make math
namespaces sequences ;
IN: compiler.cfg.gc-checks

<PRIVATE

: insert-gc-check? ( bb -- ? )
    dup kill-block?>>
    [ drop f ] [ instructions>> [ ##allocation? ] any? ] if ;

: blocks-with-gc ( cfg -- bbs )
    post-order [ insert-gc-check? ] filter ;

GENERIC# gc-check-offsets* 1 ( call-index seen-allocation? insn n -- call-index seen-allocation? )

:: gc-check-here ( call-index seen-allocation? insn insn-index -- call-index seen-allocation? )
    seen-allocation? [ call-index , ] when
    insn-index 1 + f ;

M: ##callback-inputs gc-check-offsets* gc-check-here ;
M: ##phi gc-check-offsets* gc-check-here ;
M: gc-map-insn gc-check-offsets* gc-check-here ;
M: ##allocation gc-check-offsets* 3drop t ;
M: insn gc-check-offsets* 2drop ;

: gc-check-offsets ( insns -- seq )
    ! A basic block is divided into sections by call and phi
    ! instructions. For every section with at least one
    ! allocation, record the offset of its first instruction
    ! in a sequence.
    [
        [ 0 f ] dip
        [ gc-check-offsets* ] each-index
        [ , ] [ drop ] if
    ] { } make ;

:: split-instructions ( insns seq -- insns-seq )
    ! Divide a basic block into sections, where every section
    ! other than the first requires a GC check.
    [
        insns 0 seq [| insns from to |
            from to insns subseq ,
            insns to
        ] each
        tail ,
    ] { } make ;

GENERIC: allocation-size* ( insn -- n )

M: ##allot allocation-size* size>> ;
M: ##box-alien allocation-size* drop 5 cells ;
M: ##box-displaced-alien allocation-size* drop 5 cells ;

: allocation-size ( insns -- n )
    [ ##allocation? ] filter
    [ allocation-size* data-alignment get align ] map-sum ;

: add-gc-checks ( insns-seq -- )
    ! Insert a GC check at the end of every chunk but the last
    ! one. This ensures that every section other than the first
    ! has a GC check in the section immediately preceeding it.
    2 <clumps> [
        first2 allocation-size
        cc<= int-rep next-vreg-rep int-rep next-vreg-rep
        ##check-nursery-branch new-insn
        swap push
    ] each ;

: make-blocks ( insns-seq -- bbs )
    [ f insns>block ] map ;

: <gc-call> ( -- bb )
    <basic-block>
    [ <gc-map> ##call-gc, ##branch, ] V{ } make
    >>instructions t >>unlikely? ;

:: connect-gc-checks ( bbs -- )
    ! Every basic block but the last has two successors:
    ! the next block, and a GC call.
    ! Every basic block but the first has two predecessors:
    ! the previous block, and the previous block's GC call.
    bbs length 1 - :> len
    len [ <gc-call> ] replicate :> gc-calls
    len [| n |
        n bbs nth :> bb
        n 1 + bbs nth :> next-bb
        n gc-calls nth :> gc-call
        V{ next-bb gc-call } bb successors<<
        V{ next-bb } gc-call successors<<
        V{ bb } gc-call predecessors<<
        V{ bb gc-call } next-bb predecessors<<
    ] each-integer ;

:: update-predecessor-phis ( from to bb -- )
    to [
        [
            [
                [ dup from eq? [ drop bb ] when ] dip
            ] assoc-map
        ] change-inputs drop
    ] each-phi ;

:: (insert-gc-checks) ( bb bbs -- )
    bb predecessors>> bbs first predecessors<<
    bb successors>> bbs last successors<<
    bb predecessors>> [ bb bbs first update-successors ] each
    bb successors>> [
        [ bb ] dip bbs last
        [ update-predecessors ]
        [ update-predecessor-phis ] 3bi
    ] each ;

: process-block ( bb -- )
    dup instructions>> dup gc-check-offsets split-instructions
    [ add-gc-checks ] [ make-blocks dup connect-gc-checks ] bi
    (insert-gc-checks) ;

PRIVATE>

:: insert-gc-checks ( cfg -- )
    cfg blocks-with-gc [
        cfg needs-predecessors
        [ process-block ] each
        cfg cfg-changed
    ] unless-empty ;
