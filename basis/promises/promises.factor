! Copyright (C) 2004, 2006 Chris Double, Matthew Willis.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors effects.parser generalizations kernel
sequences words continuations combinators ;
IN: promises

SYMBOLS: +unforced+ +error+ +value+ ;

TUPLE: promise quot status value ;

: <promise> ( quot -- promise ) +unforced+ f promise boa ;

: <value> ( value -- promise )
    '[ f +value+ _ promise boa ] call ;

: force ( promise -- value )
    dup status>> {
        { +error+ [ value>> throw ] }
        { +value+ [ value>> ] }
        { +unforced+ [
            dup
            [ quot>> call( -- value ) >>value +value+ >>status value>> ]
            [ >>value +error+ >>status value>> throw ]
            recover
        ] }
    } case ;

: make-lazy-quot ( quot effect -- quot )
    in>> length '[ _ _ ncurry <promise> ] ;

SYNTAX: LAZY:
    (:) [ make-lazy-quot ] keep define-declared ;
