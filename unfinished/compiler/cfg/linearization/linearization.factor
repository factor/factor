! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences namespaces make
combinators
compiler.cfg
compiler.cfg.rpo
compiler.cfg.instructions
compiler.cfg.instructions.syntax ;
IN: compiler.cfg.linearization

! Convert CFG IR to machine IR.
SYMBOL: frame-size

: compute-frame-size ( rpo -- )
    [ instructions>> [ %frame-required? ] filter ] map concat
    [ f ] [ [ n>> ] map supremum ] if-empty
    frame-size set ;

GENERIC: linearize-insn ( basic-block insn -- )

: linearize-insns ( basic-block -- )
    dup instructions>> [ linearize-insn ] with each ; inline

M: insn linearize-insn , drop ;

M: %frame-required linearize-insn 2drop ;

M: %prologue linearize-insn
    2drop frame-size get [ _prologue ] when* ;

M: %epilogue linearize-insn
    2drop frame-size get [ _epilogue ] when* ;

: useless-branch? ( basic-block successor -- ? )
    #! If our successor immediately follows us in RPO, then we
    #! don't need to branch.
    [ number>> 1+ ] [ number>> ] bi* = ; inline

: branch-to-return? ( successor -- ? )
    #! A branch to a block containing just a return is cloned.
    instructions>> dup length 2 = [
        [ first %epilogue? ] [ second %return? ] bi and
    ] [ drop f ] if ;

: emit-branch ( basic-block successor -- )
    {
        { [ 2dup useless-branch? ] [ 2drop ] }
        { [ dup branch-to-return? ] [ nip linearize-insns ] }
        [ nip label>> _branch ]
    } cond ;

M: %branch linearize-insn
    drop dup successors>> first emit-branch ;

: conditional ( basic-block -- basic-block successor1 label2 )
    dup successors>> first2 swap label>> ; inline

: boolean-conditional ( basic-block insn -- basic-block successor vreg label2 )
    [ conditional ] [ dst>> ] bi* swap ; inline

M: %branch-f linearize-insn
    boolean-conditional _branch-f emit-branch ;

M: %branch-t linearize-insn
    boolean-conditional _branch-t emit-branch ;

M: %if-intrinsic linearize-insn
    [ conditional ] [ [ quot>> ] [ vregs>> ] bi ] bi*
    _if-intrinsic emit-branch ;

M: %boolean-intrinsic linearize-insn
    [
        "false" define-label
        "end" define-label
        "false" get over [ quot>> ] [ vregs>> ] bi _if-intrinsic
        dup out>> t %load-literal
        "end" get _branch
        "false" resolve-label
        dup out>> f %load-literal
        "end" resolve-label
    ] with-scope
    2drop ;

: linearize-basic-block ( bb -- )
    [ label>> _label ] [ linearize-insns ] bi ;

: linearize-basic-blocks ( rpo -- insns )
    [ [ linearize-basic-block ] each ] { } make ;

: build-mr ( cfg -- mr )
    [
        entry>> reverse-post-order [
            [ compute-frame-size ]
            [ linearize-basic-blocks ] bi
        ] with-scope
    ] [ word>> ] [ label>> ] tri <mr> ;
