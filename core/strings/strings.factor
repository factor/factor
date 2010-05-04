! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors byte-arrays kernel math.private
sequences kernel.private math sequences.private slots.private ;
IN: strings

<PRIVATE

: string-hashcode ( str -- n ) 3 slot ; inline

: set-string-hashcode ( n str -- ) 3 set-slot ; inline

: reset-string-hashcode ( str -- )
    f swap set-string-hashcode ; inline

: rehash-string ( str -- )
    1 over sequence-hashcode swap set-string-hashcode ; inline

: (aux) ( n string -- byte-array m )
    aux>> { byte-array } declare swap 1 fixnum-shift-fast ; inline

: small-char? ( ch -- ? ) HEX: 7f fixnum<= ; inline

: string-nth ( n string -- ch )
    2dup string-nth-fast dup small-char?
    [ 2nip ] [
        [ (aux) alien-unsigned-2 7 fixnum-shift-fast ] dip
        fixnum-bitxor
    ] if ; inline

: ensure-aux ( string -- string )
    dup aux>> [ dup length 2 * (byte-array) >>aux ] unless ; inline

: set-string-nth-slow ( ch n string -- )
    [ [ HEX: 80 fixnum-bitor ] 2dip set-string-nth-fast ]
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
        2dup [ hashcode ] bi@ eq?
        [ sequence= ] [ 2drop f ] if
    ] [
        2drop f
    ] if ;

M: string hashcode*
    nip
    dup string-hashcode
    [ ] [ dup rehash-string string-hashcode ] ?if ;

M: string length
    length>> ; inline

M: string nth-unsafe
    [ >fixnum ] dip string-nth ; inline

M: string set-nth-unsafe
    dup reset-string-hashcode
    [ >fixnum ] [ >fixnum ] [ ] tri* set-string-nth ; inline

M: string clone
    (clone) [ clone ] change-aux ; inline

M: string resize resize-string ; inline

: 1string ( ch -- str ) 1 swap <string> ;

: >string ( seq -- str ) "" clone-like ;

M: string new-sequence drop 0 <string> ; inline

INSTANCE: string sequence
