! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: arrays
USING: arrays kernel kernel-internals math math-internals
sequences sequences-internals ;

M: array clone (clone) ;
M: array length array-capacity ;
M: array nth bounds-check nth-unsafe ;
M: array set-nth bounds-check set-nth-unsafe ;
M: array nth-unsafe >r >fixnum r> array-nth ;
M: array set-nth-unsafe >r >fixnum r> set-array-nth ;
M: array resize resize-array ;
: >array [ length f <array> 0 over ] keep copy-into ; inline
M: array like drop dup array? [ >array ] unless ;
: 1array 1 swap <array> ; flushable
: 2array
    2 swap <array> [ 0 swap set-array-nth ] keep ; flushable
: 3array
    3 swap <array>
    [ 1 swap set-array-nth ] keep
    [ 0 swap set-array-nth ] keep ; flushable
: zero-array 0 <array> ;

M: byte-array clone (clone) ;
M: byte-array length array-capacity ;
M: byte-array resize resize-array ;
