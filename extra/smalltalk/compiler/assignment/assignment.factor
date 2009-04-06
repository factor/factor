! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel sequences sets smalltalk.ast ;
IN: smalltalk.compiler.assignment

GENERIC: assigned-locals ( ast -- seq )

M: ast-return assigned-locals value>> assigned-locals ;

M: ast-block assigned-locals
    [ body>> assigned-locals ] [ arguments>> ] bi diff ;

M: ast-message-send assigned-locals
    [ receiver>> assigned-locals ]
    [ arguments>> assigned-locals ]
    bi append ;

M: ast-cascade assigned-locals
    [ receiver>> assigned-locals ]
    [ messages>> assigned-locals ]
    bi append ;

M: ast-message assigned-locals
    arguments>> assigned-locals ;

M: ast-assignment assigned-locals
    [ name>> dup ast-name? [ name>> 1array ] [ drop { } ] if ]
    [ value>> assigned-locals ] bi append ;

M: ast-sequence assigned-locals
    body>> assigned-locals ;

M: array assigned-locals
    [ assigned-locals ] map concat ;

M: object assigned-locals drop f ;