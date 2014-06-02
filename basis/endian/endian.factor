! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data namespaces io.binary fry
kernel math grouping sequences math.bitwise ;
IN: endian

SINGLETONS: big-endian little-endian ;

: compute-native-endianness ( -- class )
    1 int <ref> char deref 0 = big-endian little-endian ? ; foldable

SYMBOL: native-endianness
native-endianness [ compute-native-endianness ] initialize

SYMBOL: endianness
endianness [ native-endianness get-global ] initialize

HOOK: >native-endian native-endianness ( obj n -- bytes )

M: big-endian >native-endian >be ;

M: little-endian >native-endian >le ;

HOOK: unsigned-native-endian> native-endianness ( obj -- bytes )

M: big-endian unsigned-native-endian> be> ;

M: little-endian unsigned-native-endian> le> ;

: signed-native-endian> ( obj n -- n' )
    [ unsigned-native-endian> ] dip >signed ;

HOOK: >endian endianness ( obj n -- bytes )

M: big-endian >endian >be ;

M: little-endian >endian >le ;

HOOK: endian> endianness ( seq -- n )

M: big-endian endian> be> ;

M: little-endian endian> le> ;

HOOK: unsigned-endian> endianness ( obj -- bytes )

M: big-endian unsigned-endian> be> ;

M: little-endian unsigned-endian> le> ;

: signed-endian> ( obj n -- bytes )
    [ unsigned-endian> ] dip >signed ;

: with-endianness ( endian quot -- )
    [ endianness ] dip with-variable ; inline

: with-big-endian ( quot -- )
    big-endian swap with-endianness ; inline

: with-little-endian ( quot -- )
    little-endian swap with-endianness ; inline

: with-native-endian ( quot -- )
    \ native-endianness get-global swap with-endianness ; inline

: seq>native-endianness ( seq n -- seq' )
    native-endianness get-global dup endianness get = [
        2drop
    ] [
        [ [ <groups> ] keep ] dip
        little-endian = [
            '[ be> _ >le ] map
        ] [
            '[ le> _ >be ] map
        ] if concat
    ] if ; inline
