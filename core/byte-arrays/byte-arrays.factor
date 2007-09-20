! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: byte-arrays
USING: kernel kernel.private alien sequences
sequences.private math ;

M: byte-array clone (clone) ;
M: byte-array length array-capacity ;
M: byte-array nth-unsafe swap >fixnum alien-unsigned-1 ;
M: byte-array set-nth-unsafe swap >fixnum set-alien-unsigned-1 ;
: >byte-array ( seq -- byte-array ) B{ } clone-like ; inline
M: byte-array like drop dup byte-array? [ >byte-array ] unless ;
M: byte-array new drop <byte-array> ;

M: byte-array equal?
    over byte-array? [ sequence= ] [ 2drop f ] if ;

INSTANCE: byte-array sequence
