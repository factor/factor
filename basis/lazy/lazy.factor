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
            [ f ] change-quot swap '[
                _ call( -- value )
                [ >>value +value+ swap status<< ] keep
            ] [
                [ >>value +error+ swap status<< ] keep throw
            ] recover
        ] }
    } case ;

: make-lazy-quot ( quot effect -- quot )
    in>> length '[ _ _ ncurry <lazy> ] ;

SYNTAX: LAZY:
    (:) [ make-lazy-quot ] keep define-declared ;
