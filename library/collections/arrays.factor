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

: >array ( seq -- array ) [ f <array> ] >sequence ; inline

M: array like drop dup array? [ >array ] unless ;

M: byte-array clone (clone) ;
M: byte-array length array-capacity ;
M: byte-array resize resize-array ;

: 1array ( x -- { x } ) 1 swap <array> ; flushable

: 2array ( x y -- { x y } )
    2 swap <array> [ 0 swap set-array-nth ] keep ; flushable

: 3array ( x y z -- { x y z } )
    3 swap <array>
    [ 1 swap set-array-nth ] keep
    [ 0 swap set-array-nth ] keep ; flushable
