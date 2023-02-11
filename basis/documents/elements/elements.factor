! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators documents kernel math
math.order sequences unicode ;
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
        { [ pick second zero? ] [ drop [ first 1 - ] dip line-end ] }
        [ call ]
    } cond ; inline

: next ( loc document quot: ( loc document -- loc ) -- loc )
    {
        { [ 2over doc-end = ] [ 2drop ] }
        { [ 2over line-end? ] [ 2drop first 1 + 0 2array ] }
        [ call ]
    } cond ; inline

: modify-col ( loc document quot: ( col str -- col' ) -- loc )
    pick [
        [ [ first2 swap ] dip doc-line ] dip call
    ] dip =col ; inline

PRIVATE>

M: char-elt prev-elt
    drop [ [ last-grapheme-from ] modify-col ] prev ;

M: char-elt next-elt
    drop [ [ first-grapheme-from ] modify-col ] next ;

SINGLETON: one-char-elt

M: one-char-elt prev-elt 2drop ;

M: one-char-elt next-elt 2drop ;

<PRIVATE

: blank-at? ( n seq -- n seq ? )
    2dup ?nth unicode:blank? ;

: break-detector ( ? -- quot )
    '[ unicode:blank? _ xor ] ; inline

: prev-word ( col str ? -- col )
    break-detector find-last-from drop ?1+ ;

: next-word ( col str ? -- col )
    [ break-detector find-from drop ] [ drop length ] 2bi or ;

PRIVATE>

SINGLETON: one-word-elt

M: one-word-elt prev-elt
    drop
    [ [ 1 - ] dip f prev-word ] modify-col ;

M: one-word-elt next-elt
    drop
    [ f next-word ] modify-col ;

SINGLETON: word-start-elt

M: word-start-elt prev-elt
    drop one-word-elt prev-elt ;

M: word-start-elt next-elt 2drop ;

SINGLETON: word-elt

M: word-elt prev-elt
    drop
    [ [ [ 1 - ] dip blank-at? prev-word ] modify-col ]
    prev ;

M: word-elt next-elt
    drop
    [ [ blank-at? next-word ] modify-col ]
    next ;

SINGLETON: one-line-elt

M: one-line-elt prev-elt
    2drop first 0 2array ;

M: one-line-elt next-elt
    drop [ first dup ] dip doc-line length 2array ;

<PRIVATE

:: prev-paragraph ( loc document -- loc' )
    loc first 1 [-] document value>>
    [ empty? ] find-last-from drop [ 1 + ] [ 0 ] if* :> line#

    loc first line# = loc second 0 = and [
        line# 1 [-] 0 2array
    ] [
        line# 0 2array
    ] if ;

:: next-paragraph ( loc document -- loc' )
    loc first 1 + document value>>
    [ empty? ] find-from drop :> line#

    line# [
        1 - dup document doc-line length 2array
        dup loc = [ first 1 + 0 2array ] when
    ] [
        document doc-end
    ] if* ;

PRIVATE>

SINGLETON: paragraph-elt

M: paragraph-elt prev-elt drop prev-paragraph ;

M: paragraph-elt next-elt drop next-paragraph ;

TUPLE: page-elt { #lines integer read-only } ;

C: <page-elt> page-elt

M: page-elt prev-elt
    nip
    2dup [ first ] [ #lines>> ] bi* <
    [ 2drop { 0 0 } ] [ #lines>> neg +line ] if ;

M: page-elt next-elt
    3dup [ first ] [ last-line# ] [ #lines>> ] tri* - >
    [ drop nip doc-end ] [ nip #lines>> +line ] if ;

CONSTANT: line-elt T{ page-elt { #lines 1 } }

SINGLETON: doc-elt

M: doc-elt prev-elt 3drop { 0 0 } ;

M: doc-elt next-elt drop nip doc-end ;
