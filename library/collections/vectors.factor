! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: vectors
USING: arrays errors generic kernel kernel-internals math
math-internals sequences sequences-internals words ;

M: vector set-length ( len vec -- )
    grow-length ;

M: vector nth-unsafe ( n vec -- obj ) underlying nth-unsafe ;

M: vector nth ( n vec -- obj ) bounds-check nth-unsafe ;

M: vector set-nth-unsafe ( obj n vec -- )
    underlying set-nth-unsafe ;

M: vector set-nth ( obj n vec -- )
    growable-check 2dup ensure set-nth-unsafe ;

: >vector ( seq -- vector ) [ <vector> ] >sequence ; inline

M: object thaw drop V{ } clone ;

M: vector clone ( vector -- vector ) clone-growable ;

M: vector like
    drop dup vector? [
        dup array? [ array>vector ] [ >vector ] if
    ] unless ;

IN: kernel

: with-datastack ( stack word -- stack )
    datastack >r >r >vector set-datastack r> execute
    datastack r> [ push ] keep set-datastack 2nip ;
