! Copyright (C) 2003, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors byte-arrays kernel
kernel.private math math.private sequences sequences.private
slots.private ;
IN: strings

BUILTIN: string { length array-capacity read-only initial: 0 } aux ;

PRIMITIVE: <string> ( n ch -- string )
PRIMITIVE: resize-string ( n str -- newstr )

<PRIVATE
PRIMITIVE: set-string-nth-fast ( ch n string -- )
PRIMITIVE: string-nth-fast ( n string -- ch )

: string-hashcode ( str -- n ) 3 slot ; inline

: set-string-hashcode ( n str -- ) 3 set-slot ; inline

: reset-string-hashcode ( str -- )
    f swap set-string-hashcode ; inline

: rehash-string ( str -- )
    0 over [
        swap [
            [ -2 fixnum-shift-fast ] [ 5 fixnum-shift-fast ] bi
            fixnum+fast fixnum+fast
        ] keep fixnum-bitxor
    ] each swap set-string-hashcode ; inline

: (aux) ( n string -- byte-array m )
    aux>> { byte-array } declare swap 1 fixnum-shift-fast ; inline

: small-char? ( ch -- ? )
    dup 0 fixnum>= [ 0x7f fixnum<= ] [ drop f ] if ; inline

: string-nth ( n string -- ch )
    2dup string-nth-fast dup small-char?
    [ 2nip ] [
        [ (aux) alien-unsigned-2 7 fixnum-shift-fast ] dip
        fixnum-bitxor
    ] if ; inline

: ensure-aux ( string -- string )
    dup aux>> [ dup length 2 * (byte-array) >>aux ] unless ; inline

: set-string-nth-slow ( ch n string -- )
    [ [ 0x80 fixnum-bitor ] 2dip set-string-nth-fast ]
    [
        ensure-aux
        [ -7 fixnum-shift-fast 1 fixnum-bitxor ] 2dip
        (aux) set-alien-unsigned-2
    ] 3bi ;

: set-string-nth ( ch n string -- )
    pick small-char?
    [ set-string-nth-fast ] [ set-string-nth-slow ] if ; inline

PRIVATE>

M: string equal?
    over string? [
        ! faster during bootstrap than ``[ hashcode ] bi@``
        over hashcode over hashcode eq?
        [ sequence= ] [ 2drop f ] if
    ] [
        2drop f
    ] if ;

M: string hashcode*
    nip
    [ string-hashcode ]
    [ dup rehash-string string-hashcode ] ?unless ;

M: string length
    length>> ; inline

M: string nth-unsafe
    [ integer>fixnum ] dip string-nth ; inline

M: string set-nth-unsafe
    dup reset-string-hashcode
    [ integer>fixnum ] [ integer>fixnum ] [ ] tri* set-string-nth ; inline

M: string clone
    (clone) [ clone ] change-aux ; inline

M: string clone-like
    over string? [ drop clone ] [ call-next-method ] if ; inline

M: string resize resize-string ; inline

: 1string ( ch -- str ) 1 swap <string> ; inline

: >string ( seq -- str ) "" clone-like ; inline

M: string new-sequence drop 0 <string> ; inline

INSTANCE: string sequence
