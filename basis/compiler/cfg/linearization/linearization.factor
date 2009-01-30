! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences namespaces make
combinators classes
compiler.cfg
compiler.cfg.rpo
compiler.cfg.instructions ;
IN: compiler.cfg.linearization

! Convert CFG IR to machine IR.
GENERIC: linearize-insn ( basic-block insn -- )

: linearize-insns ( basic-block -- )
    dup instructions>> [ linearize-insn ] with each ; inline

M: insn linearize-insn , drop ;

: useless-branch? ( basic-block successor -- ? )
    #! If our successor immediately follows us in RPO, then we
    #! don't need to branch.
    [ number>> ] bi@ 1- = ; inline

: branch-to-branch? ( successor -- ? )
    #! A branch to a block containing just a jump return is cloned.
    instructions>> dup length 2 = [
        [ first ##epilogue? ]
        [ second [ ##return? ] [ ##jump? ] bi or ] bi and
    ] [ drop f ] if ;

: emit-branch ( basic-block successor -- )
    {
        { [ 2dup useless-branch? ] [ 2drop ] }
        { [ dup branch-to-branch? ] [ nip linearize-insns ] }
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

: gc? ( bb -- ? )
    instructions>> [
        class {
            ##allot
            ##integer>bignum
            ##box-float
            ##box-alien
        } memq?
    ] any? ;

: linearize-basic-block ( bb -- )
    [ number>> _label ]
    [ gc? [ _gc ] when ]
    [ linearize-insns ]
    tri ;

: linearize-basic-blocks ( rpo -- insns )
    [ [ linearize-basic-block ] each ] { } make ;

: build-mr ( cfg -- mr )
    [ entry>> reverse-post-order linearize-basic-blocks ]
    [ word>> ] [ label>> ]
    tri <mr> ;
