! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences
USING: arrays kernel kernel-internals errors generic math
math-internals strings ;

GENERIC: length ( seq -- n )
GENERIC: set-length ( n seq -- )
GENERIC: nth ( n seq -- elt )
GENERIC: set-nth ( elt n seq -- )
GENERIC: new ( len seq -- newseq )
GENERIC: new-resizable ( len seq -- newseq )
GENERIC: like ( seq prototype -- newseq )

M: object new drop f <array> ;

M: object like drop ;

: empty? ( seq -- ? ) length zero? ; inline

: midpoint@ length 2/ ; inline

: delete-all ( seq -- ) 0 swap set-length ;

: lengthen ( n seq -- )
    2dup length > [ set-length ] [ 2drop ] if ; inline

: first ( seq -- first ) 0 swap nth ; inline
: second ( seq -- second ) 1 swap nth ; inline
: third ( seq -- third ) 2 swap nth ; inline
: fourth  ( seq -- fourth ) 3 swap nth ; inline

: push ( elt seq -- ) dup length swap set-nth ;

: ?push ( elt seq/f -- seq )
    [ 1 f new-resizable ] unless* [ push ] keep ;

: bounds-check? ( n seq -- ? )
    over 0 >= [ length < ] [ 2drop f ] if ; inline

TUPLE: bounds-error index seq ;

: bounds-error ( n seq -- * ) <bounds-error> throw ;

: bounds-check ( n seq -- n seq )
    2dup bounds-check? [ bounds-error ] unless ; inline

IN: sequences-internals

DEFER: max-array-capacity

PREDICATE: fixnum array-capacity
    0 max-array-capacity between? ;

: array-capacity ( array -- n )
    1 slot { array-capacity } declare ; inline

: array-nth ( n array -- elt )
    swap 2 fixnum+fast slot ; inline

: set-array-nth ( elt n array -- )
    swap 2 fixnum+fast set-slot ; inline

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
M: f nth bounds-error ;
M: f nth-unsafe nip ;
M: f like drop dup empty? [ drop f ] when ;
M: f new drop dup zero? [ drop f ] [ f <array> ] if ;

! Integers support the sequence protocol
M: integer length ;
M: integer nth bounds-check drop ;
M: integer nth-unsafe drop ;

: first2-unsafe
    [ 0 swap nth-unsafe ] keep 1 swap nth-unsafe ; inline

: first3-unsafe
    [ first2-unsafe ] keep 2 swap nth-unsafe ; inline

: first4-unsafe
    [ first3-unsafe ] keep 3 swap nth-unsafe ; inline

: exchange-unsafe ( m n seq -- )
    [ tuck nth-unsafe >r nth-unsafe r> ] 3keep tuck
    >r >r set-nth-unsafe r> r> set-nth-unsafe ; inline

IN: sequences

: singleton ( obj exemplar -- seq )
    1 swap new [ 0 swap set-nth-unsafe ] keep ; inline

: first2 ( seq -- first second )
    1 swap bounds-check nip first2-unsafe ;

: first3 ( seq -- first second third )
    2 swap bounds-check nip first3-unsafe ;

: first4 ( seq -- first second third fourth )
    3 swap bounds-check nip first4-unsafe ;

: ?nth ( n seq/f -- elt/f )
    2dup bounds-check? [ nth-unsafe ] [ 2drop f ] if ;
