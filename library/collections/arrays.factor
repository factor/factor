! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

IN: kernel-internals
USING: kernel math math-internals sequences sequences-internals ;

: array= ( seq seq -- ? )
    #! This is really only used to compare tuples.
    over array-capacity over array-capacity number= [
        dup array-capacity [
            >r 2dup r> tuck swap array-nth >r swap array-nth r> =
        ] all? 2nip
    ] [
        2drop f
    ] if ; flushable

IN: arrays

M: array clone (clone) ;
M: array length array-capacity ;
M: array nth bounds-check array-nth ;
M: array set-nth bounds-check set-array-nth ;
M: array nth-unsafe >r >fixnum r> array-nth ;
M: array set-nth-unsafe >r >fixnum r> set-array-nth ;
M: array resize resize-array ;

: >array ( seq -- array )
    [ length <array> 0 over ] keep copy-into ; inline

M: array like drop dup array? [ >array ] unless ;

M: byte-array clone (clone) ;
M: byte-array length array-capacity ;
M: byte-array resize resize-array ;

: 1array ( x -- @{ x }@ )
    1 <array> [ 0 swap set-array-nth ] keep ; flushable

: 2array ( x y -- @{ x y }@ )
    2 <array>
    [ 1 swap set-array-nth ] keep
    [ 0 swap set-array-nth ] keep ; flushable

: 3array ( x y z -- @{ x y z }@ )
    3 <array>
    [ 2 swap set-array-nth ] keep
    [ 1 swap set-array-nth ] keep
    [ 0 swap set-array-nth ] keep ; flushable

: zero-array ( n -- array ) 0 <repeated> >array ;
