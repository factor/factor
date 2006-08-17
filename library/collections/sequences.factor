! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences
USING: errors generic kernel math math-internals strings vectors ;

GENERIC: length ( seq -- n )
GENERIC: set-length ( n seq -- )
GENERIC: nth ( n seq -- elt )
GENERIC: set-nth ( elt n seq -- )
GENERIC: thaw ( seq -- resizable-seq )
GENERIC: like ( seq prototype -- newseq )

: empty? ( seq -- ? ) length zero? ; inline

: delete-all ( seq -- ) 0 swap set-length ;

: first ( seq -- first ) 0 swap nth ; inline
: second ( seq -- second ) 1 swap nth ; inline
: third ( seq -- third ) 2 swap nth ; inline
: fourth  ( seq -- fourth ) 3 swap nth ; inline

: push ( elt seq -- ) dup length swap set-nth ;

: ?push ( elt seq/f -- seq )
    [ 1 <vector> ] unless* [ push ] keep ;

: bounds-check? ( n seq -- ? )
    over 0 >= [ length < ] [ 2drop f ] if ; inline

IN: sequences-internals

GENERIC: resize ( n seq -- newseq )

! Unsafe sequence protocol for inner loops
GENERIC: nth-unsafe ( n seq -- elt )
GENERIC: set-nth-unsafe ( elt n seq -- )

M: object nth-unsafe nth ;
M: object set-nth-unsafe set-nth ;

: 2nth-unsafe ( s s n -- x x )
    tuck swap nth-unsafe >r swap nth-unsafe r> ; inline

! The f object supports the sequence protocol trivially
M: f length drop 0 ;
M: f nth nip ;
M: f nth-unsafe nip ;
M: f like drop dup empty? [ drop f ] when ;

! Integers support the sequence protocol
M: integer length ;
M: integer nth drop ;
M: integer nth-unsafe drop ;

: first2-unsafe
    [ 0 swap nth-unsafe ] keep 1 swap nth-unsafe ; inline

: first3-unsafe
    [ first2-unsafe ] keep 2 swap nth-unsafe ; inline

: first4-unsafe
    [ first3-unsafe ] keep 3 swap nth-unsafe ; inline

: exchange-unsafe ( n n seq -- )
    [ tuck nth-unsafe >r nth-unsafe r> ] 3keep tuck
    >r >r set-nth-unsafe r> r> set-nth-unsafe ; inline

IN: sequences

: ?nth ( n seq/f -- elt/f )
    2dup bounds-check? [ nth-unsafe ] [ 2drop f ] if ;
