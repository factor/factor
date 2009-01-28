! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators documents fry kernel math sequences
unicode.categories ;
IN: documents.elements

GENERIC: prev-elt ( loc document elt -- newloc )
GENERIC: next-elt ( loc document elt -- newloc )

: prev/next-elt ( loc document elt -- start end )
    [ prev-elt ] [ next-elt ] 3bi ;

: elt-string ( loc document elt -- string )
    [ prev/next-elt ] [ drop ] 2bi doc-range ;

: set-elt-string ( string loc document elt -- )
    [ prev/next-elt ] [ drop ] 2bi set-doc-range ;

SINGLETON: char-elt

<PRIVATE

: (prev-char) ( loc document quot -- loc )
    {
        { [ pick { 0 0 } = ] [ 2drop ] }
        { [ pick second zero? ] [ drop [ first 1- ] dip line-end ] }
        [ call ]
    } cond ; inline

: (next-char) ( loc document quot -- loc )
    {
        { [ 2over doc-end = ] [ 2drop ] }
        { [ 2over line-end? ] [ 2drop first 1+ 0 2array ] }
        [ call ]
    } cond ; inline

PRIVATE>

M: char-elt prev-elt
    drop [ drop -1 +col ] (prev-char) ;

M: char-elt next-elt
    drop [ drop 1 +col ] (next-char) ;

SINGLETON: one-char-elt

M: one-char-elt prev-elt 2drop ;

M: one-char-elt next-elt 2drop ;

<PRIVATE

: (word-elt) ( loc document quot -- loc )
    pick [
        [ [ first2 swap ] dip doc-line ] dip call
    ] dip =col ; inline

: ((word-elt)) ( n seq -- ? n seq )
    [ ?nth blank? ] 2keep ;

: break-detector ( ? -- quot )
    '[ blank? _ xor ] ; inline

: (prev-word) ( ? col str -- col )
    rot break-detector find-last-from drop ?1+ ;

: (next-word) ( ? col str -- col )
    [ rot break-detector find-from drop ] keep
    over not [ nip length ] [ drop ] if ;

PRIVATE>

SINGLETON: one-word-elt

M: one-word-elt prev-elt
    drop
    [ [ [ f ] dip 1- ] dip (prev-word) ] (word-elt) ;

M: one-word-elt next-elt
    drop
    [ [ f ] 2dip (next-word) ] (word-elt) ;

SINGLETON: word-elt

M: word-elt prev-elt
    drop
    [ [ [ 1- ] dip ((word-elt)) (prev-word) ] (word-elt) ]
    (prev-char) ;

M: word-elt next-elt
    drop
    [ [ ((word-elt)) (next-word) ] (word-elt) ]
    (next-char) ;

SINGLETON: one-line-elt

M: one-line-elt prev-elt
    2drop first 0 2array ;

M: one-line-elt next-elt
    drop [ first dup ] dip doc-line length 2array ;

SINGLETON: line-elt

M: line-elt prev-elt
    2drop dup first zero? [ drop { 0 0 } ] [ -1 +line ] if ;

M: line-elt next-elt
    drop over first over last-line# number=
    [ nip doc-end ] [ drop 1 +line ] if ;

SINGLETON: doc-elt

M: doc-elt prev-elt 3drop { 0 0 } ;

M: doc-elt next-elt drop nip doc-end ;