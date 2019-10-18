! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: vectors
USING: arrays errors generic kernel kernel-internals math
math-internals sequences sequences-internals words ;

: <vector> ( n -- vector )
    f <array> array>vector 0 over set-fill ; inline

M: vector set-length grow-length ;

M: vector nth-unsafe underlying nth-unsafe ;

M: vector nth bounds-check nth-unsafe ;

M: vector set-nth-unsafe
    underlying set-nth-unsafe ;

M: vector set-nth
    growable-check 2dup ensure set-nth-unsafe ;

: >vector ( seq -- vector ) V{ } clone-like ; inline

M: vector clone clone-resizable ;

M: vector like
    drop dup vector? [
        dup array? [ array>vector ] [ >vector ] if
    ] unless ;

M: vector new drop dup <vector> tuck set-length ;

M: vector equal?
    over vector? [ sequence= ] [ 2drop f ] if ;

M: object new-resizable drop <vector> ;
