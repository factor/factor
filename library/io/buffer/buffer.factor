! Copyright (C) 2004, 2005 Mackenzie Straight.
! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io-internals
USING: alien errors kernel kernel-internals libc math sequences
strings ;

TUPLE: buffer size ptr fill pos ;

C: buffer ( n -- buffer )
    2dup set-buffer-size
    [ >r malloc check-ptr alien-address r> set-buffer-ptr ] keep
    0 over set-buffer-fill
    0 over set-buffer-pos ;

: buffer-free ( buffer -- )
    dup buffer-ptr <alien> free  0 swap set-buffer-ptr ;

: buffer-contents ( buffer -- string )
    dup buffer-ptr over buffer-pos +
    over buffer-fill rot buffer-pos - memory>string ;

: buffer-reset ( n buffer -- )
    [ set-buffer-fill ] keep 0 swap set-buffer-pos ;

: buffer-consume ( n buffer -- )
    [ buffer-pos + ] keep
    [ buffer-fill min ] keep
    [ set-buffer-pos ] keep
    dup buffer-pos over buffer-fill >= [
        0 over set-buffer-pos
        0 over set-buffer-fill
    ] when drop ;

: buffer@ ( buffer -- n ) dup buffer-ptr swap buffer-pos + ;

: buffer-end ( buffer -- n ) dup buffer-ptr swap buffer-fill + ;

: buffer-first-n ( n buffer -- string )
    [ dup buffer-fill swap buffer-pos - min ] keep
    buffer@ swap memory>string ;

: buffer> ( n buffer -- string )
    [ buffer-first-n ] 2keep buffer-consume ;

: buffer>> ( buffer -- string )
    [ buffer-contents ] keep 0 swap buffer-reset ;

: buffer-length ( buffer -- n )
    dup buffer-fill swap buffer-pos - ;

: buffer-capacity ( buffer -- n )
    dup buffer-size swap buffer-fill - ;

: buffer-empty? ( buffer -- ? ) buffer-fill zero? ;

: extend-buffer ( n buffer -- )
    2dup buffer-ptr <alien> swap realloc check-ptr alien-address
    over set-buffer-ptr set-buffer-size ;

: check-overflow ( n buffer -- )
    2dup buffer-capacity > [ extend-buffer ] [ 2drop ] if ;

: >buffer ( string buffer -- )
    over length over check-overflow
    [ buffer-end string>memory ] 2keep
    [ buffer-fill swap length + ] keep set-buffer-fill ;

: ch>buffer ( ch buffer -- )
    1 over check-overflow
    [ buffer-end f swap set-alien-unsigned-1 ] keep
    [ buffer-fill 1+ ] keep set-buffer-fill ;

: buffer-bound ( buffer -- n )
    dup buffer-ptr swap buffer-size + ;

: n>buffer ( n buffer -- )
    [ buffer-fill + ] keep 
    [ buffer-bound > [ "Buffer overflow" throw ] when ] 2keep
    set-buffer-fill ;

: buffer-peek ( buffer -- ch )
    buffer@ f swap alien-unsigned-1 ;

: buffer-pop ( buffer -- ch )
    [ buffer-peek  1 ] keep buffer-consume ;

PROVIDE: library/io/buffer ;
