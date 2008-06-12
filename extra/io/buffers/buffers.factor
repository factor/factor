! Copyright (C) 2004, 2005 Mackenzie Straight.
! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.c-types
alien.syntax kernel libc math sequences byte-arrays strings
hints accessors math.order destructors combinators ;
IN: io.buffers

TUPLE: buffer size ptr fill pos disposed ;

: <buffer> ( n -- buffer )
    dup malloc 0 0 f buffer boa ;

M: buffer dispose* ptr>> free ;

: buffer-reset ( n buffer -- )
    swap >>fill 0 >>pos drop ;

: buffer-capacity ( buffer -- n )
    [ size>> ] [ fill>> ] bi - ; inline

: buffer-empty? ( buffer -- ? )
    fill>> zero? ;

: buffer-consume ( n buffer -- )
    [ + ] change-pos
    dup [ pos>> ] [ fill>> ] bi <
    [ 0 >>pos 0 >>fill ] unless drop ; inline

: buffer-peek ( buffer -- byte )
    [ ptr>> ] [ pos>> ] bi alien-unsigned-1 ; inline

: buffer-pop ( buffer -- byte )
    [ buffer-peek ] [ 1 swap buffer-consume ] bi ;

HINTS: buffer-pop buffer ;

: buffer-length ( buffer -- n )
    [ fill>> ] [ pos>> ] bi - ; inline

: buffer@ ( buffer -- alien )
    [ pos>> ] [ ptr>> ] bi <displaced-alien> ;

: buffer-read ( n buffer -- byte-array )
    [ buffer-length min ] keep
    [ buffer@ ] [ buffer-consume ] 2bi
    swap memory>byte-array ;

HINTS: buffer-read fixnum buffer ;

: extend-buffer ( n buffer -- )
    2dup ptr>> swap realloc >>ptr swap >>size drop ;
    inline

: check-overflow ( n buffer -- )
    2dup buffer-capacity > [ extend-buffer ] [ 2drop ] if ;
    inline

: buffer-end ( buffer -- alien )
    [ fill>> ] [ ptr>> ] bi <displaced-alien> ; inline

: n>buffer ( n buffer -- )
    [ + ] change-fill
    [ fill>> ] [ size>> ] bi >
    [ "Buffer overflow" throw ] when ; inline

: >buffer ( byte-array buffer -- )
    [ [ length ] dip check-overflow ]
    [ buffer-end byte-array>memory ]
    [ [ length ] dip n>buffer ]
    2tri ;

HINTS: >buffer byte-array buffer ;

: byte>buffer ( byte buffer -- )
    [ 1 swap check-overflow ]
    [ [ ptr>> ] [ fill>> ] bi set-alien-unsigned-1 ]
    [ 1 swap n>buffer ]
    tri ;

HINTS: byte>buffer fixnum buffer ;

: search-buffer-until ( pos fill ptr separators -- n )
    [ [ swap alien-unsigned-1 ] dip memq? ] 2curry find-from drop ;

: finish-buffer-until ( buffer n -- byte-array separator )
    [
        over pos>> -
        over buffer-read
        swap buffer-pop
    ] [
        [ buffer-length ] keep
        buffer-read f
    ] if* ;

: buffer-until ( separators buffer -- byte-array separator )
    swap [ { [ ] [ pos>> ] [ fill>> ] [ ptr>> ] } cleave ] dip
    search-buffer-until
    finish-buffer-until ;

HINTS: buffer-until { string buffer } ;
