! Copyright (C) 2004, 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: alien errors kernel kernel-internals math strings ;

TUPLE: buffer size ptr fill pos ;

: imalloc ( size -- address )
    "int" "libc" "malloc" [ "int" ] alien-invoke ;

: ifree ( address -- )
    "void" "libc" "free" [ "int" ] alien-invoke ;

: irealloc ( address size -- address )
    "int" "libc" "realloc" [ "int" "int" ] alien-invoke ;

C: buffer ( size -- buffer )
    2dup set-buffer-size
    swap imalloc swap [ set-buffer-ptr ] keep
    0 swap [ set-buffer-fill ] keep
    0 swap [ set-buffer-pos ] keep ;

: buffer-free ( buffer -- )
    #! Frees the C memory associated with the buffer.
    dup buffer-ptr ifree  0 swap set-buffer-ptr ;

: buffer-contents ( buffer -- string )
    #! Returns the current contents of the buffer.
    dup buffer-ptr over buffer-pos +
    over buffer-fill rot buffer-pos - memory>string ;

: buffer-first-n ( count buffer -- string )
    [ dup buffer-fill swap buffer-pos - min ] keep
    dup buffer-ptr swap buffer-pos + swap memory>string ;

: buffer-reset ( count buffer -- )
    #! Reset the position to 0 and the fill pointer to count.
    [ set-buffer-fill ] keep 0 swap set-buffer-pos ;

: buffer-consume ( count buffer -- )
    #! Consume count characters from the beginning of the buffer.
    [ buffer-pos + ] keep
    [ buffer-fill min ] keep
    [ set-buffer-pos ] keep
    dup buffer-pos over buffer-fill = [
        [ 0 swap set-buffer-pos ] keep
        [ 0 swap set-buffer-fill ] keep
    ] when drop ;

: buffer-length ( buffer -- length )
    #! Returns the amount of unconsumed input in the buffer.
    dup buffer-fill swap buffer-pos - 0 max ;

: buffer-capacity ( buffer -- int )
    #! Returns the amount of data that may be added to the buffer.
    dup buffer-size swap buffer-fill - ;

: buffer-set ( string buffer -- )
    2dup buffer-ptr string>memory
    >r string-length r> buffer-reset ;

: check-overflow ( string buffer -- )
    buffer-capacity swap string-length < [
        "Buffer overflow" throw
    ] when ;

: buffer-append ( string buffer -- )
    2dup check-overflow
    [ dup buffer-ptr swap buffer-fill + string>memory ] 2keep
    [ buffer-fill swap string-length + ] keep set-buffer-fill ;

: buffer-append-char ( int buffer -- )
    #! Append a single character to a buffer
    [
        dup buffer-ptr swap buffer-fill +
        <alien> 0 set-alien-signed-1
    ] keep
    [ buffer-fill 1 + ] keep set-buffer-fill ;

: buffer-extend ( length buffer -- )
    #! Increases the size of the buffer by length.
    [ buffer-size + dup ] keep [ buffer-ptr swap ] keep
    >r irealloc r>
    [ set-buffer-ptr ] keep set-buffer-size ;

: buffer-inc-fill ( count buffer -- )
    #! Increases the fill pointer by count.
    [ buffer-fill + ] keep set-buffer-fill ;

: buffer-pos+ptr ( buffer -- int )
    [ buffer-ptr ] keep buffer-pos + ;
