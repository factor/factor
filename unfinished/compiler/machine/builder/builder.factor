! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences namespaces make
compiler.cfg compiler.instructions compiler.machine ;
IN: compiler.machine.builder

! Convert CFG IR to machine IR.

SYMBOL: block-counter

: number-basic-block ( basic-block -- )
    #! Make this fancy later.
    dup number>> [ drop ] [
        <label> >>label
        block-counter [ dup 1+ ] change >>number
        [ , ] [
            successors>> <reversed>
            [ number-basic-block ] each
        ] bi
    ] if ;

: flatten-basic-blocks ( procedure -- blocks )
    [
        0 block-counter
        [ number-basic-block ]
        with-variable
    ] { } make ;

GENERIC: linearize* ( basic-block insn -- )

M: object linearize* , drop ;

M: %branch linearize*
    drop successors>> first label>> _branch ;

: conditional ( basic-block -- label1 label2 )
    successors>> first2 [ label>> ] bi@ swap ; inline

: boolean-conditional ( basic-block insn -- label1 vreg label2 )
    [ conditional ] [ vreg>> ] bi* swap ; inline

M: %branch-f linearize*
    boolean-conditional _branch-f _branch ;

M: %branch-t linearize*
    boolean-conditional _branch-t _branch ;

M: %if-intrinsic linearize*
    [ conditional ] [ [ quot>> ] [ vregs>> ] bi ] bi*
    _if-intrinsic _branch ;

M: %boolean-intrinsic linearize*
    [
        "false" define-label
        "end" define-label
        "false" get over [ quot>> ] [ vregs>> ] bi _if-intrinsic
        t over out>> %load-literal
        "end" get _branch
        "false" resolve-label
        f over out>> %load-literal
        "end" resolve-label
    ] with-scope
    2drop ;

: build-machine ( procedure -- insns )
    [
        entry>> flatten-basic-blocks [
            [ label>> _label ]
            [ dup instructions>> [ linearize* ] with each ]
            bi
        ] each
    ] { } make ;
