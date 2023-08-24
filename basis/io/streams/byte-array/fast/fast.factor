! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien byte-arrays byte-vectors io kernel libc math
sequences ;

! This is split off from io.streams.byte-array because it uses
! memcpy, which is a non-core word that only works after the
! optimizing compiler has been loaded.

M: byte-vector stream-write
    over byte-array? [
        push-all ! faster than memcpy
    ] [
        2dup [ byte-length ] bi@
        3dup + swap lengthen
        [ tail-slice swap ] curry dip memcpy
    ] if ;
