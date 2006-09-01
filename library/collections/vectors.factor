! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: vectors
USING: arrays errors generic kernel kernel-internals math
math-internals sequences sequences-internals words ;

M: vector set-length
    grow-length ;

M: vector nth-unsafe underlying nth-unsafe ;

M: vector nth bounds-check nth-unsafe ;

M: vector set-nth-unsafe
    underlying set-nth-unsafe ;

M: vector set-nth
    growable-check 2dup ensure set-nth-unsafe ;

: >vector ( seq -- vector )
    [ vector? ] [ <vector> ] >sequence ; inline

M: object thaw drop V{ } clone ;

M: vector clone clone-resizable ;

M: vector like
    drop dup vector? [
        dup array? [ array>vector ] [ >vector ] if
    ] unless ;

IN: kernel

: with-datastack ( stack word -- newstack )
    datastack >r >r >vector set-datastack r> execute
    datastack r> [ push ] keep set-datastack 2nip ;
