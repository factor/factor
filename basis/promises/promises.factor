! Copyright (C) 2004, 2006 Chris Double, Matthew Willis.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors effects.parser generalizations kernel
sequences words ;
IN: promises

TUPLE: promise quot forced? value ;

: <promise> ( quot -- promise ) f f promise boa ;

: force ( promise -- value )
    dup forced?>> [
        dup quot>> call( -- value ) >>value
        t >>forced?
    ] unless value>> ;

: make-lazy-quot ( quot effect -- quot )
    in>> length '[ _ _ ncurry <promise> ] ;

SYNTAX: LAZY:
    (:) [ make-lazy-quot ] keep define-declared ;
