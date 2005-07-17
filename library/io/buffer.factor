! Copyright (C) 2004, 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
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
    #! Frees the C memory associated with the buffer.
    dup buffer-ptr free  0 swap set-buffer-ptr ;

: buffer-contents ( buffer -- string )
    #! Returns the current contents of the buffer.
    dup buffer-ptr over buffer-pos +
    over buffer-fill rot buffer-pos - memory>string ;

: buffer-reset ( count buffer -- )
    #! Reset the position to 0 and the fill pointer to count.
    [ set-buffer-fill ] keep 0 swap set-buffer-pos ;

: buffer-consume ( count buffer -- )
    #! Consume count characters from the beginning of the buffer.
    [ buffer-pos + ] keep
    [ buffer-fill min ] keep
    [ set-buffer-pos ] keep
    dup buffer-pos over buffer-fill = [
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
    #! Returns the amount of unconsumed input in the buffer.
    dup buffer-fill swap buffer-pos - ;

: buffer-capacity ( buffer -- int )
    #! Returns the amount of data that may be added to the buffer.
    dup buffer-size swap buffer-fill - ;

: eof? ( buffer -- ? ) buffer-fill 0 = ;

: buffer-extend ( length buffer -- )
    #! Increases the size of the buffer by length.
    2dup buffer-ptr swap realloc check-ptr
    over set-buffer-ptr set-buffer-size ;

: check-overflow ( length buffer -- )
    2dup buffer-capacity > [
        dup eof? [
            buffer-extend
        ] [
            "Buffer overflow" throw
        ] ifte
    ] [
        2drop
    ] ifte ;

: >buffer ( string buffer -- )
    over length over check-overflow
    [ buffer-end string>memory ] 2keep
    [ buffer-fill swap length + ] keep set-buffer-fill ;

: ch>buffer ( char buffer -- )
    1 over check-overflow
    [ buffer-end <alien> 0 set-alien-unsigned-1 ] keep
    [ buffer-fill 1 + ] keep set-buffer-fill ;

: n>buffer ( count buffer -- )
    #! Increases the fill pointer by count.
    [ buffer-fill + ] keep set-buffer-fill ;

: buffer-peek ( buffer -- char )
    buffer@ <alien> 0 alien-unsigned-1 ;

: buffer-pop ( buffer -- char )
    [ buffer-peek  1 ] keep buffer-consume ;
