! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences namespaces make
combinators assocs arrays locals cpu.architecture
compiler.cfg
compiler.cfg.rpo
compiler.cfg.liveness
compiler.cfg.stack-frame
compiler.cfg.instructions ;
IN: compiler.cfg.linearization

! Convert CFG IR to machine IR.
GENERIC: linearize-insn ( basic-block insn -- )

: linearize-basic-block ( bb -- )
    [ number>> _label ]
    [ dup instructions>> [ linearize-insn ] with each ]
    bi ;

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

: with-regs ( insn quot -- )
    over regs>> [ call ] dip building get last (>>regs) ; inline

M: ##compare-branch linearize-insn
    [ binary-conditional _compare-branch ] with-regs emit-branch ;

M: ##compare-imm-branch linearize-insn
    [ binary-conditional _compare-imm-branch ] with-regs emit-branch ;

M: ##compare-float-branch linearize-insn
    [ binary-conditional _compare-float-branch ] with-regs emit-branch ;

M: ##dispatch linearize-insn
    swap
    [ [ [ src>> ] [ temp>> ] bi _dispatch ] with-regs ]
    [ successors>> [ number>> _dispatch-label ] each ]
    bi* ;

: gc-root-registers ( n live-registers -- n )
    [
        [ second 2array , ]
        [ first reg-class>> reg-size + ]
        2bi
    ] each ;

: gc-root-spill-slots ( n live-spill-slots -- n )
    [
        dup first reg-class>> int-regs eq? [
            [ second <spill-slot> 2array , ]
            [ first reg-class>> reg-size + ]
            2bi
        ] [ drop ] if
    ] each ;

: oop-registers ( regs -- regs' )
    [ first reg-class>> int-regs eq? ] filter ;

: data-registers ( regs -- regs' )
    [ first reg-class>> double-float-regs eq? ] filter ;

:: compute-gc-roots ( live-registers live-spill-slots -- alist )
    [
        0
        ! we put float registers last; the GC doesn't actually scan them
        live-registers oop-registers gc-root-registers
        live-spill-slots gc-root-spill-slots
        live-registers data-registers gc-root-registers
        drop
    ] { } make ;

: count-gc-roots ( live-registers live-spill-slots -- n )
    ! Size of GC root area, minus the float registers
    [ oop-registers length ] bi@ + ;

M: ##gc linearize-insn
    nip
    [
        [ temp1>> ]
        [ temp2>> ]
        [
            [ live-registers>> ] [ live-spill-slots>> ] bi
            [ compute-gc-roots ]
            [ count-gc-roots ]
            [ gc-roots-size ]
            2tri
        ] tri
        _gc
    ] with-regs ;

: linearize-basic-blocks ( cfg -- insns )
    [
        [ [ linearize-basic-block ] each-basic-block ]
        [ spill-counts>> _spill-counts ]
        bi
    ] { } make ;

: flatten-cfg ( cfg -- mr )
    [ linearize-basic-blocks ] [ word>> ] [ label>> ] tri
    <mr> ;
