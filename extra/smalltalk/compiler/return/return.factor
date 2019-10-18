! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.short-circuit continuations
fry generalizations kernel locals locals.types locals.rewrite.closures
namespaces make sequences smalltalk.ast ;
IN: smalltalk.compiler.return

SYMBOL: return-continuation

GENERIC: need-return-continuation? ( ast -- ? )

M: ast-return need-return-continuation? drop t ;

M: ast-block need-return-continuation? body>> need-return-continuation? ;

M: ast-message-send need-return-continuation?
    {
        [ receiver>> need-return-continuation? ]
        [ arguments>> need-return-continuation? ]
    } 1|| ;

M: ast-cascade need-return-continuation?
    {
        [ receiver>> need-return-continuation? ]
        [ messages>> need-return-continuation? ]
    } 1|| ;

M: ast-message need-return-continuation?
    arguments>> need-return-continuation? ;

M: ast-assignment need-return-continuation?
    value>> need-return-continuation? ;

M: ast-sequence need-return-continuation?
    body>> need-return-continuation? ;

M: array need-return-continuation? [ need-return-continuation? ] any? ;

M: object need-return-continuation? drop f ;

:: make-return ( quot n lexenv block -- quot )
    block need-return-continuation? [
        quot clone [ lexenv return>> <def> '[ _ ] prepend ] change-body
        n '[ _ _ ncurry callcc1 ]
    ] [ quot ] if rewrite-closures first ;