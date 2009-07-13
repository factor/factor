! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences namespaces make
combinators assocs arrays locals cpu.architecture
compiler.cfg
compiler.cfg.rpo
compiler.cfg.liveness
compiler.cfg.comparisons
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

: emit-branch ( basic-block successor -- )
    2dup useless-branch? [ 2drop ] [ nip number>> _branch ] if ;

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

: (compute-gc-roots) ( n live-values -- n )
    [
        [ nip 2array , ]
        [ drop reg-class>> reg-size + ]
        3bi
    ] assoc-each ;

: oop-values ( regs -- regs' )
    [ drop reg-class>> int-regs eq? ] assoc-filter ;

: data-values ( regs -- regs' )
    [ drop reg-class>> double-float-regs eq? ] assoc-filter ;

: compute-gc-roots ( live-values -- alist )
    [
        [ 0 ] dip
        ! we put float registers last; the GC doesn't actually scan them
        [ oop-values (compute-gc-roots) ]
        [ data-values (compute-gc-roots) ] bi
        drop
    ] { } make ;

: count-gc-roots ( live-values -- n )
    ! Size of GC root area, minus the float registers
    oop-values assoc-size ;

M: ##gc linearize-insn
    nip
    [
        [ temp1>> ]
        [ temp2>> ]
        [
            live-values>>
            [ compute-gc-roots ]
            [ count-gc-roots ]
            [ gc-roots-size ]
            tri
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
