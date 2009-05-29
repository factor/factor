! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences namespaces make
combinators assocs
cpu.architecture
compiler.cfg
compiler.cfg.rpo
compiler.cfg.liveness
compiler.cfg.instructions ;
IN: compiler.cfg.linearization

! Convert CFG IR to machine IR.
GENERIC: linearize-insn ( basic-block insn -- )

: linearize-insns ( bb insns -- )
    [ linearize-insn ] with each ;

: gc? ( bb -- ? )
    instructions>> [ ##allocation? ] any? ;

: object-pointer-regs ( basic-block -- vregs )
    live-out keys [ reg-class>> int-regs eq? ] filter ;

: gc-check-position ( insns -- n )
    #! We want to insert the GC check before the final branch in a basic block.
    #! If there is a ##epilogue or ##loop-entry we want to insert it before that too.
    dup length
    dup 2 >= [
        2 - swap nth [ ##loop-entry? ] [ ##epilogue? ] bi or
        2 1 ?
    ] [ 2drop 1 ] if ;

: linearize-basic-block/gc ( bb -- )
    dup instructions>> dup gc-check-position
    [ head* linearize-insns ]
    [ 2drop object-pointer-regs _gc ]
    [ tail* linearize-insns ]
    3tri ;

: linearize-basic-block ( bb -- )
    [ number>> _label ]
    [
        dup gc?
        [ linearize-basic-block/gc ]
        [ dup instructions>> linearize-insns ] if
    ] bi ;

M: insn linearize-insn , drop ;

: useless-branch? ( basic-block successor -- ? )
    #! If our successor immediately follows us in RPO, then we
    #! don't need to branch.
    [ number>> ] bi@ 1 - = ; inline

: branch-to-branch? ( successor -- ? )
    #! A branch to a block containing just a jump return is cloned.
    instructions>> dup length 2 = [
        [ first ##epilogue? ]
        [ second [ ##return? ] [ ##jump? ] bi or ] bi and
    ] [ drop f ] if ;

: emit-branch ( basic-block successor -- )
    {
        { [ 2dup useless-branch? ] [ 2drop ] }
        { [ dup branch-to-branch? ] [ nip linearize-basic-block ] }
        [ nip number>> _branch ]
    } cond ;

M: ##branch linearize-insn
    drop dup successors>> first emit-branch ;

: (binary-conditional) ( basic-block insn -- basic-block successor1 successor2 src1 src2 cc )
    [ dup successors>> first2 ]
    [ [ src1>> ] [ src2>> ] [ cc>> ] tri ] bi* ; inline

: binary-conditional ( basic-block insn -- basic-block successor label2 src1 src2 cc )
    [ (binary-conditional) ]
    [ drop dup successors>> second useless-branch? ] 2bi
    [ [ swap number>> ] 3dip ] [ [ number>> ] 3dip negate-cc ] if ;

M: ##compare-branch linearize-insn
    binary-conditional _compare-branch emit-branch ;

M: ##compare-imm-branch linearize-insn
    binary-conditional _compare-imm-branch emit-branch ;

M: ##compare-float-branch linearize-insn
    binary-conditional _compare-float-branch emit-branch ;

M: ##dispatch linearize-insn
    swap
    [ [ src>> ] [ temp>> ] bi _dispatch ]
    [ successors>> [ number>> _dispatch-label ] each ]
    bi* ;

: linearize-basic-blocks ( rpo -- insns )
    [ [ linearize-basic-block ] each ] { } make ;

: build-mr ( cfg -- mr )
    [ reverse-post-order linearize-basic-blocks ]
    [ word>> ] [ label>> ]
    tri <mr> ;
