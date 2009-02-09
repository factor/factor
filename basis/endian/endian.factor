! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types namespaces io.binary fry
kernel math ;
IN: endian

SINGLETONS: big-endian little-endian ;

: native-endianness ( -- class )
    1 <int> *char 0 = big-endian little-endian ? ;

: >signed ( x n -- y )
    2dup neg 1+ shift 1 = [ 2^ - ] [ drop ] if ;

native-endianness \ native-endianness set-global

SYMBOL: endianness

\ native-endianness get-global endianness set-global

HOOK: >native-endian native-endianness ( obj n -- str )

M: big-endian >native-endian >be ;

M: little-endian >native-endian >le ;

HOOK: unsigned-native-endian> native-endianness ( obj -- str )

M: big-endian unsigned-native-endian> be> ;

M: little-endian unsigned-native-endian> le> ;

: signed-native-endian> ( obj n -- str )
    [ unsigned-native-endian> ] dip >signed ;

HOOK: >endian endianness ( obj n -- str )

M: big-endian >endian >be ;

M: little-endian >endian >le ;

HOOK: endian> endianness ( seq -- n )

M: big-endian endian> be> ;

M: little-endian endian> le> ;

HOOK: unsigned-endian> endianness ( obj -- str )

M: big-endian unsigned-endian> be> ;

M: little-endian unsigned-endian> le> ;

: signed-endian> ( obj n -- str )
    [ unsigned-endian> ] dip >signed ;

: with-endianness ( endian quot -- )
    [ endianness ] dip with-variable ; inline

: with-big-endian ( quot -- )
    big-endian swap with-endianness ; inline

: with-little-endian ( quot -- )
    little-endian swap with-endianness ; inline

: with-native-endian ( quot -- )
    \ native-endianness get-global swap with-endianness ; inline
