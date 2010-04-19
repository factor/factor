! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math.private sequences kernel.private
math sequences.private slots.private alien.accessors ;
IN: strings

<PRIVATE

: string-hashcode ( str -- n ) 3 slot ; inline

: set-string-hashcode ( n str -- ) 3 set-slot ; inline

: reset-string-hashcode ( str -- )
    f swap set-string-hashcode ; inline

: rehash-string ( str -- )
    1 over sequence-hashcode swap set-string-hashcode ; inline

: set-string-nth ( ch n string -- )
    pick HEX: 7f fixnum<=
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
