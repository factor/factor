! Copyright (C) 2004, 2006 Chris Double, Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays effects fry generalizations kernel math
namespaces parser effects.parser sequences words ;
IN: promises

TUPLE: promise-state quot forced? value ;

: promise ( quot -- promise ) f f \ promise-state boa ;

: force ( promise -- value )
    dup forced?>> [
        dup quot>> call( -- value ) >>value
        t >>forced?
    ] unless
    value>> ;

: make-lazy-quot ( quot effect -- quot )
    in>> length '[ _ _ ncurry promise ] ;

SYNTAX: LAZY:
    (:) [ make-lazy-quot ] [ 2nip ] 3bi define-declared ;
