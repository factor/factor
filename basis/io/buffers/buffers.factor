! Copyright (C) 2004, 2005 Mackenzie Straight.
! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.data byte-arrays
combinators destructors kernel libc math math.order math.private
sequences sequences.private typed ;
IN: io.buffers

TUPLE: buffer
{ size fixnum }
{ ptr alien }
{ fill fixnum }
{ pos fixnum }
disposed ;

: <buffer> ( n -- buffer )
    dup malloc 0 0 f buffer boa ; inline

M: buffer dispose* ptr>> free ; inline

TYPED: buffer-reset ( n: fixnum buffer: buffer -- )
    swap >>fill 0 >>pos drop ; inline

TYPED: buffer-capacity ( buffer: buffer -- n )
    [ size>> ] [ fill>> ] bi fixnum-fast ; inline

TYPED: buffer-empty? ( buffer: buffer -- ? )
    fill>> zero? ; inline

TYPED: buffer-consume ( n: fixnum buffer: buffer -- )
    [ fixnum+fast ] change-pos
    dup [ pos>> ] [ fill>> ] bi <
    [ 0 >>pos 0 >>fill ] unless drop ; inline

TYPED: buffer-peek ( buffer: buffer -- byte )
    [ ptr>> ] [ pos>> ] bi alien-unsigned-1 ; inline

TYPED: buffer-pop ( buffer: buffer -- byte )
    [ buffer-peek ] [ 1 swap buffer-consume ] bi ; inline

TYPED: buffer-length ( buffer: buffer -- n )
    [ fill>> ] [ pos>> ] bi fixnum-fast ; inline

TYPED: buffer@ ( buffer: buffer -- alien )
    [ pos>> ] [ ptr>> ] bi <displaced-alien> ; inline

TYPED: buffer-read-unsafe ( n: fixnum buffer: buffer -- n ptr )
    [ buffer-length min ] keep
    [ buffer@ ] [ buffer-consume ] 2bi ; inline

TYPED: buffer-read ( n: fixnum buffer: buffer -- byte-array )
    buffer-read-unsafe swap memory>byte-array ; inline

TYPED: buffer-read-into ( dst n: fixnum buffer: buffer -- count )
    buffer-read-unsafe swap [
        pick c-ptr? [
            memcpy
        ] [
            spin
            [ swap alien-unsigned-1 ]
            [ set-nth-unsafe ] bi-curry*
            [ bi ] 2curry each-integer
        ] if
    ] keep ; inline

TYPED: buffer-end ( buffer: buffer -- alien )
    [ fill>> ] [ ptr>> ] bi <displaced-alien> ; inline

TYPED: buffer+ ( n: fixnum buffer: buffer -- )
    [ fixnum+fast ] change-fill drop ; inline

TYPED: buffer-write ( c-ptr n buffer: buffer -- )
    [ buffer-end -rot memcpy ] [ buffer+ ] 2bi ; inline

TYPED: buffer-write1 ( byte: fixnum buffer: buffer -- )
    [ [ ptr>> ] [ fill>> ] bi set-alien-unsigned-1 ]
    [ 1 swap buffer+ ] bi ; inline

TYPED: buffer-find ( seps buffer: buffer -- n/f )
    [
        swap [ [ pos>> ] [ fill>> ] [ ptr>> ] tri ] dip
        [ swap alien-unsigned-1 ] [ member-eq? ] bi-curry*
        compose find-integer-from
    ] [
        [ pos>> - ] curry [ f ] if*
    ] bi ; inline

<PRIVATE

: search-buffer-until ( seps buffer -- buffer n/f )
    [ buffer-find ] guard ; inline

: finish-buffer-until ( buffer n -- byte-array sep/f )
    [
        over buffer-read
        swap buffer-pop
    ] [
        [ buffer-length ] keep
        buffer-read f
    ] if* ; inline

PRIVATE>

TYPED: buffer-read-until ( seps buffer: buffer -- byte-array sep/f )
    search-buffer-until
    finish-buffer-until ;
