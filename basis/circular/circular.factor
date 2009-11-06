! Copyright (C) 2005, 2006 Alex Chapman, Daniel Ehrenberg
! See http;//factorcode.org/license.txt for BSD license
USING: kernel sequences math sequences.private strings
accessors ;
IN: circular

! a circular sequence wraps another sequence, but begins at an
! arbitrary element in the underlying sequence.
TUPLE: circular seq start ;

: <circular> ( seq -- circular )
    0 circular boa ;

<PRIVATE
: circular-wrap ( n circular -- n circular )
    [ start>> + ] keep
    [ seq>> length rem ] keep ; inline
PRIVATE>

M: circular length seq>> length ;

M: circular virtual@ circular-wrap seq>> ;

M: circular virtual-exemplar seq>> ;

: change-circular-start ( n circular -- )
    #! change start to (start + n) mod length
    circular-wrap (>>start) ;

: rotate-circular ( circular -- )
    [ 1 ] dip change-circular-start ;

: push-circular ( elt circular -- )
    [ set-first ] [ rotate-circular ] bi ;

: <circular-string> ( n -- circular )
    0 <string> <circular> ;

INSTANCE: circular virtual-sequence

TUPLE: growing-circular < circular length ;

M: growing-circular length length>> ;

<PRIVATE

: full? ( circular -- ? )
    [ length ] [ seq>> length ] bi = ;

PRIVATE>

: push-growing-circular ( elt circular -- )
    dup full? [ push-circular ]
    [ [ 1 + ] change-length set-last ] if ;

: <growing-circular> ( capacity -- growing-circular )
    { } new-sequence 0 0 growing-circular boa ;
