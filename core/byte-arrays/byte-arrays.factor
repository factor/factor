! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors kernel math sequences
sequences.private ;
IN: byte-arrays

BUILTIN: byte-array
{ length array-capacity read-only initial: 0 } ;

M: byte-array clone (clone) ; inline
M: byte-array clone-like
    over byte-array? [ drop clone ] [ call-next-method ] if ; inline
M: byte-array length length>> ; inline
M: byte-array nth-unsafe swap integer>fixnum alien-unsigned-1 ; inline
M: byte-array set-nth-unsafe swap integer>fixnum set-alien-unsigned-1 ; inline
: >byte-array ( seq -- byte-array ) B{ } clone-like ; inline
M: byte-array new-sequence drop (byte-array) ; inline

M: byte-array equal?
    over byte-array? [ sequence= ] [ 2drop f ] if ;

M: byte-array resize
    resize-byte-array ; inline

INSTANCE: byte-array sequence

: 1byte-array ( x -- byte-array ) B{ } 1sequence ; inline

: 2byte-array ( x y -- byte-array ) B{ } 2sequence ; inline

: 3byte-array ( x y z -- byte-array ) B{ } 3sequence ; inline

: 4byte-array ( w x y z -- byte-array ) B{ } 4sequence ; inline
