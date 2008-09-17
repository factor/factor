! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences namespaces
compiler.cfg compiler.vops compiler.lvops ;
IN: compiler.machine.builder

SYMBOL: block-counter

: number-basic-block ( basic-block -- )
    #! Make this fancy later.
    dup number>> [ drop ] [
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

GENERIC: linearize-instruction ( basic-block insn -- )

M: object linearize-instruction
    , drop ;

M: %b linearize-instruction
    drop successors>> first number>> _b emit ;

: conditional-branch ( basic-block insn class -- )
    [ successors>> ] 2dip
    [ [ first number>> ] [ [ in>> ] [ code>> ] bi ] [ ] tri* emit ]
    [ 2drop second number>> _b emit ]
    3bi ; inline

M: %bi linearize-instruction _bi conditional-branch ;
M: %bf linearize-instruction _bf conditional-branch ;

: build-mr ( procedure -- insns )
    [
        flatten-basic-blocks [
            [ number>> _label emit ]
            [ dup instructions>> [ linearize-instruction ] with each ]
            bi
        ] each
    ] { } make ;
