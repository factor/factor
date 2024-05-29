! Copyright (C) 2004, 2006 Chris Double, Matthew Willis.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors effects.parser generalizations kernel
sequences words continuations combinators ;
IN: lazy

SYMBOLS: +unforced+ +error+ +value+ ;

TUPLE: lazy quot status value ;

: <lazy> ( quot -- lazy ) +unforced+ f lazy boa ;

: <value> ( value -- lazy ) [ f +value+ ] dip lazy boa ;

: force ( lazy -- value )
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
    in>> length '[ _ _ ncurry <lazy> ] ;

SYNTAX: LAZY:
    (:) [ make-lazy-quot ] keep define-declared ;
