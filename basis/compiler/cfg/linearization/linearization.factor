! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences namespaces make
combinators assocs arrays locals layouts hashtables
cpu.architecture generalizations
compiler.cfg
compiler.cfg.comparisons
compiler.cfg.stack-frame
compiler.cfg.instructions
compiler.cfg.utilities
compiler.cfg.linearization.order ;
IN: compiler.cfg.linearization

<PRIVATE

SYMBOL: numbers

: block-number ( bb -- n ) numbers get at ;

: number-blocks ( bbs -- ) [ 2array ] map-index >hashtable numbers set ;

! Convert CFG IR to machine IR.
GENERIC: linearize-insn ( basic-block insn -- )

: linearize-basic-block ( bb -- )
    [ block-number _label ]
    [ dup instructions>> [ linearize-insn ] with each ]
    bi ;

M: insn linearize-insn , drop ;

: useless-branch? ( basic-block successor -- ? )
    ! If our successor immediately follows us in linearization
    ! order then we don't need to branch.
    [ block-number ] bi@ 1 - = ; inline

: emit-branch ( bb successor -- )
    2dup useless-branch? [ 2drop ] [ nip block-number _branch ] if ;

M: ##branch linearize-insn
    drop dup successors>> first emit-branch ;

: successors ( bb -- first second ) successors>> first2 ; inline

:: conditional ( bb insn n conditional-quot negate-cc-quot -- bb successor label ... )
    bb insn
    conditional-quot
    [ drop dup successors>> second useless-branch? ] 2bi
    [ [ swap block-number ] n ndip ]
    [ [ block-number ] n ndip negate-cc-quot call ] if ; inline

: (binary-conditional) ( bb insn -- bb successor1 successor2 src1 src2 cc )
    [ dup successors ]
    [ [ src1>> ] [ src2>> ] [ cc>> ] tri ] bi* ; inline

: binary-conditional ( bb insn -- bb successor label2 src1 src2 cc )
    3 [ (binary-conditional) ] [ negate-cc ] conditional ;

: (test-vector-conditional) ( bb insn -- bb successor1 successor2 src1 temp rep vcc )
    [ dup successors ]
    [ { [ src1>> ] [ temp>> ] [ rep>> ] [ vcc>> ] } cleave ] bi* ; inline

: test-vector-conditional ( bb insn -- bb successor label src1 temp rep vcc )
    4 [ (test-vector-conditional) ] [ negate-vcc ] conditional ;

M: ##compare-branch linearize-insn
    binary-conditional _compare-branch emit-branch ;

M: ##compare-imm-branch linearize-insn
    binary-conditional _compare-imm-branch emit-branch ;

M: ##compare-float-ordered-branch linearize-insn
    binary-conditional _compare-float-ordered-branch emit-branch ;

M: ##compare-float-unordered-branch linearize-insn
    binary-conditional _compare-float-unordered-branch emit-branch ;

M: ##test-vector-branch linearize-insn
    test-vector-conditional _test-vector-branch emit-branch ;

: overflow-conditional ( bb insn -- bb successor label2 dst src1 src2 )
    [ dup successors block-number ]
    [ [ dst>> ] [ src1>> ] [ src2>> ] tri ] bi* ; inline

M: ##fixnum-add linearize-insn
    overflow-conditional _fixnum-add emit-branch ;

M: ##fixnum-sub linearize-insn
    overflow-conditional _fixnum-sub emit-branch ;

M: ##fixnum-mul linearize-insn
    overflow-conditional _fixnum-mul emit-branch ;

M: ##dispatch linearize-insn
    swap
    [ [ src>> ] [ temp>> ] bi _dispatch ]
    [ successors>> [ block-number _dispatch-label ] each ]
    bi* ;

: gc-root-offsets ( registers -- alist )
    ! Outputs a sequence of { offset register/spill-slot } pairs
    [ length iota [ cell * ] map ] keep zip ;

M: ##gc linearize-insn
    nip
    {
        [ temp1>> ]
        [ temp2>> ]
        [ data-values>> ]
        [ tagged-values>> gc-root-offsets ]
        [ uninitialized-locs>> ]
    } cleave
    _gc ;

: linearize-basic-blocks ( cfg -- insns )
    [
        [
            linearization-order
            [ number-blocks ]
            [ [ linearize-basic-block ] each ] bi
        ] [ spill-area-size>> _spill-area-size ] bi
    ] { } make ;

PRIVATE>
        
: flatten-cfg ( cfg -- mr )
    [ linearize-basic-blocks ] [ word>> ] [ label>> ] tri
    <mr> ;
