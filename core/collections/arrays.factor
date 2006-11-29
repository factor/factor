! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: arrays
USING: kernel kernel-internals math math-internals sequences
sequences-internals ;

M: array clone (clone) ;
M: array length array-capacity ;
M: array nth bounds-check nth-unsafe ;
M: array set-nth bounds-check set-nth-unsafe ;
M: array nth-unsafe >r >fixnum r> array-nth ;
M: array set-nth-unsafe >r >fixnum r> set-array-nth ;
M: array resize resize-array ;

: >array ( seq -- array )
    [ array? ] [ f <array> ] >sequence ; inline

M: array like drop dup array? [ >array ] unless ;

M: byte-array clone (clone) ;
M: byte-array length array-capacity ;
M: byte-array resize resize-array ;

: 1array ( x -- array ) 1 swap <array> ;

: 2array ( x y -- array )
    2 swap <array> [ 0 swap set-array-nth ] keep ;

: 3array ( x y z -- array )
    3 swap <array>
    [ 1 swap set-array-nth ] keep
    [ 0 swap set-array-nth ] keep ;

: 4array ( x y z t -- array )
    4 swap <array>
    [ 2 swap set-array-nth ] keep
    [ 1 swap set-array-nth ] keep
    [ 0 swap set-array-nth ] keep ;
