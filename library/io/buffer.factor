! Copyright (C) 2004, 2005 Mackenzie Straight.
! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io-internals
USING: alien errors kernel kernel-internals math sequences
strings ;

TUPLE: buffer size ptr fill pos ;

C: buffer ( size -- buffer )
    2dup set-buffer-size
    [ >r malloc check-ptr r> set-buffer-ptr ] keep
    0 over set-buffer-fill
    0 over set-buffer-pos ;

: buffer-free ( buffer -- )
    dup buffer-ptr free  0 swap set-buffer-ptr ;

: buffer-contents ( buffer -- string )
    dup buffer-ptr over buffer-pos +
    over buffer-fill rot buffer-pos - memory>string ;

: buffer-reset ( count buffer -- )
    [ set-buffer-fill ] keep 0 swap set-buffer-pos ;

: buffer-consume ( count buffer -- )
    [ buffer-pos + ] keep
    [ buffer-fill min ] keep
    [ set-buffer-pos ] keep
    dup buffer-pos over buffer-fill >= [
        0 over set-buffer-pos
        0 over set-buffer-fill
    ] when drop ;

: buffer@ ( buffer -- int ) dup buffer-ptr swap buffer-pos + ;

: buffer-end ( buffer -- int ) dup buffer-ptr swap buffer-fill + ;

: buffer-first-n ( count buffer -- string )
    [ dup buffer-fill swap buffer-pos - min ] keep
    buffer@ swap memory>string ;

: buffer> ( count buffer -- string )
    [ buffer-first-n ] 2keep buffer-consume ;

: buffer>> ( buffer -- string )
    [ buffer-contents ] keep 0 swap buffer-reset ;

: buffer-length ( buffer -- length )
    dup buffer-fill swap buffer-pos - ;

: buffer-capacity ( buffer -- int )
    dup buffer-size swap buffer-fill - ;

: buffer-empty? ( buffer -- ? ) buffer-fill zero? ;

: buffer-extend ( length buffer -- )
    2dup buffer-ptr swap realloc check-ptr
    over set-buffer-ptr set-buffer-size ;

: buffer-overflow ( ? quot -- )
    [ "Buffer overflow" throw ] if ; inline

: check-overflow ( length buffer -- )
    2dup buffer-capacity > [
        dup buffer-empty? [ buffer-extend ] buffer-overflow
    ] [
        2drop
    ] if ;

: >buffer ( string buffer -- )
    over length over check-overflow
    [ buffer-end string>memory ] 2keep
    [ buffer-fill swap length + ] keep set-buffer-fill ;

: ch>buffer ( char buffer -- )
    1 over check-overflow
    [ buffer-end f swap set-alien-unsigned-1 ] keep
    [ buffer-fill 1+ ] keep set-buffer-fill ;

: buffer-bound ( buffer -- n )
    dup buffer-ptr swap buffer-size + ;

: n>buffer ( count buffer -- )
    [ buffer-fill + ] keep 
    [ buffer-bound <= [ ] buffer-overflow ] 2keep
    set-buffer-fill ;

: buffer-peek ( buffer -- char )
    buffer@ f swap alien-unsigned-1 ;

: buffer-pop ( buffer -- char )
    [ buffer-peek  1 ] keep buffer-consume ;
