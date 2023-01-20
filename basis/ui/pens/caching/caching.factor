! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel ;
IN: ui.pens.caching

! A pen that caches vertex arrays, etc
TUPLE: caching-pen last-dim ;

GENERIC: recompute-pen ( gadget pen -- )

: compute-pen ( gadget pen -- )
    2dup [ dim>> ] [ last-dim>> ] bi* eq? [
        2drop
    ] [
        [ swap dim>> >>last-dim drop ] [ recompute-pen ] 2bi
    ] if ;
