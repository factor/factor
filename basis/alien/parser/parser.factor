! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays assocs effects grouping kernel
parser sequences splitting words fry locals ;
IN: alien.parser

: parse-arglist ( parameters return -- types effect )
    [ 2 group unzip [ "," ?tail drop ] map ]
    [ [ { } ] [ 1array ] if-void ]
    bi* <effect> ;

: function-quot ( return library function types -- quot )
    '[ _ _ _ _ alien-invoke ] ;

:: define-function ( return library function parameters -- )
    function create-in dup reset-generic
    return library function
    parameters return parse-arglist [ function-quot ] dip
    define-declared ;
