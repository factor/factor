! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators documents fry kernel math sequences
accessors unicode.categories combinators.short-circuit ;
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

: prev ( loc document quot: ( loc document -- loc ) -- loc )
    {
        { [ pick { 0 0 } = ] [ 2drop ] }
        { [ pick second zero? ] [ drop [ first 1- ] dip line-end ] }
        [ call ]
    } cond ; inline

: next ( loc document quot: ( loc document -- loc )
    {
        { [ 2over doc-end = ] [ 2drop ] }
        { [ 2over line-end? ] [ 2drop first 1+ 0 2array ] }
        [ call ]
    } cond ; inline

PRIVATE>

M: char-elt prev-elt
    drop [ drop -1 +col ] prev ;

M: char-elt next-elt
    drop [ drop 1 +col ] next ;

SINGLETON: one-char-elt

M: one-char-elt prev-elt 2drop ;

M: one-char-elt next-elt 2drop ;

<PRIVATE

: (word-elt) ( loc document quot -- loc )
    pick [
        [ [ first2 swap ] dip doc-line ] dip call
    ] dip =col ; inline

: blank-at? ( n seq -- n seq ? )
    2dup ?nth blank? ;

: break-detector ( ? -- quot )
    '[ blank? _ xor ] ; inline

: (prev-word) ( col str ? -- col )
    break-detector find-last-from drop ?1+ ;

: (next-word) ( col str ? -- col )
    { [ break-detector find-from drop ] [ drop length ] } 2|| ;

PRIVATE>

SINGLETON: one-word-elt

M: one-word-elt prev-elt
    drop
    [ [ 1- ] dip f (prev-word) ] (word-elt) ;

M: one-word-elt next-elt
    drop
    [ f (next-word) ] (word-elt) ;

SINGLETON: word-elt

M: word-elt prev-elt
    drop
    [ [ [ 1- ] dip blank-at? (prev-word) ] (word-elt) ]
    prev ;

M: word-elt next-elt
    drop
    [ [ blank-at? (next-word) ] (word-elt) ]
    next ;

SINGLETON: one-line-elt

M: one-line-elt prev-elt
    2drop first 0 2array ;

M: one-line-elt next-elt
    drop [ first dup ] dip doc-line length 2array ;

TUPLE: page-elt { lines read-only } ;

C: <page-elt> page-elt

M: page-elt prev-elt
    nip
    2dup [ first ] [ lines>> ] bi* <
    [ 2drop { 0 0 } ] [ lines>> neg +line ] if ;

M: page-elt next-elt
    3dup [ first ] [ last-line# ] [ lines>> ] tri* - >
    [ drop nip doc-end ] [ nip lines>> +line ] if ;

CONSTANT: line-elt T{ page-elt f 1 }

SINGLETON: doc-elt

M: doc-elt prev-elt 3drop { 0 0 } ;

M: doc-elt next-elt drop nip doc-end ;
