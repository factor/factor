! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors ascii grouping kernel
kernel.private lexer math math.parser parser sequences
sequences.private ;
IN: byte-arrays

SYNTAX: HEX{
    "}" parse-tokens "" join
    [ blank? not ] filter
    2 group [ hex> ] B{ } map-as
    parsed ;

M: byte-array clone (clone) ;
M: byte-array length length>> ;
M: byte-array nth-unsafe swap >fixnum alien-unsigned-1 ;
M: byte-array set-nth-unsafe swap >fixnum set-alien-unsigned-1 ;
: >byte-array ( seq -- byte-array ) B{ } clone-like ; inline
M: byte-array new-sequence drop (byte-array) ;

M: byte-array equal?
    over byte-array? [ sequence= ] [ 2drop f ] if ;

M: byte-array resize
    resize-byte-array ;

INSTANCE: byte-array sequence

: 1byte-array ( x -- byte-array ) B{ } 1sequence ; inline

: 2byte-array ( x y -- byte-array ) B{ } 2sequence ; inline

: 3byte-array ( x y z -- byte-array ) B{ } 3sequence ; inline

: 4byte-array ( w x y z -- byte-array ) B{ } 4sequence ; inline
