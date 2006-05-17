! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences
USING: errors generic kernel math math-internals strings vectors ;

GENERIC: length ( sequence -- n ) flushable
GENERIC: set-length ( n sequence -- )
GENERIC: nth ( n sequence -- obj ) flushable
GENERIC: set-nth ( value n sequence -- obj )
GENERIC: thaw ( seq -- mutable-seq ) flushable
GENERIC: like ( seq seq -- seq ) flushable

: empty? ( seq -- ? ) length zero? ; inline

: first 0 swap nth ; inline
: second 1 swap nth ; inline
: third 2 swap nth ; inline
: fourth 3 swap nth ; inline

: push ( element sequence -- )
    dup length swap set-nth ;

: ?push ( elt seq/f -- seq )
    [ 1 <vector> ] unless* [ push ] keep ;

: bounds-check? ( n seq -- ? )
    over 0 >= [ length < ] [ 2drop f ] if ; inline

: ?nth ( n seq/f -- elt/f )
    2dup bounds-check? [ nth ] [ 2drop f ] if ;

IN: sequences-internals

GENERIC: resize ( n seq -- seq )

! Unsafe sequence protocol for inner loops
GENERIC: nth-unsafe
GENERIC: set-nth-unsafe

M: object nth-unsafe nth ;
M: object set-nth-unsafe set-nth ;

: 2nth-unsafe ( s s n -- x x )
    tuck swap nth-unsafe >r swap nth-unsafe r> ; inline

: change-nth-unsafe ( seq i quot -- )
    pick pick >r >r >r swap nth-unsafe
    r> call r> r> swap set-nth-unsafe ; inline

! The f object supports the sequence protocol trivially
M: f length drop 0 ;
M: f nth nip ;
M: f nth-unsafe nip ;

! Integers support the sequence protocol
M: integer length ;
M: integer nth drop ;
M: integer nth-unsafe drop ;

: first2-unsafe [ 0 swap nth-unsafe ] keep 1 swap nth-unsafe ; inline
: first3-unsafe [ first2-unsafe ] keep 2 swap nth-unsafe ; inline
: first4-unsafe [ first3-unsafe ] keep 3 swap nth-unsafe ; inline

: exchange-unsafe ( n n seq -- )
    [ tuck nth-unsafe >r nth-unsafe r> ] 3keep tuck
    >r >r set-nth-unsafe r> r> set-nth-unsafe ; inline
