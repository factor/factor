! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien byte-vectors io kernel libc math sequences ;
IN: io.streams.byte-array.fast

! This is split off from io.streams.byte-array because it uses
! memcpy, which is a non-core word that only works after the
! optimizing compiler has been loaded.

M: byte-vector stream-write
    [ dup byte-length tail-slice ]
    [ [ [ byte-length ] bi@ + ] keep lengthen ]
    [ drop byte-length ]
    2tri
    [ >c-ptr swap >c-ptr ] dip memcpy ;
