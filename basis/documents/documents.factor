! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays io kernel math models namespaces make
sequences strings splitting combinators unicode.categories
math.order math.ranges fry ;
IN: documents

: +col ( loc n -- newloc ) [ first2 ] dip + 2array ;

: +line ( loc n -- newloc ) [ first2 swap ] dip + swap 2array ;

: =col ( n loc -- newloc ) first swap 2array ;

: =line ( n loc -- newloc ) second 2array ;

: lines-equal? ( loc1 loc2 -- ? ) [ first ] bi@ number= ;

TUPLE: document < model locs ;

: <document> ( -- document )
    V{ "" } clone document new-model
    V{ } clone >>locs ;

: add-loc ( loc document -- ) locs>> push ;

: remove-loc ( loc document -- ) locs>> delete ;

: update-locs ( loc document -- )
    locs>> [ set-model ] with each ;

: doc-line ( n document -- string ) value>> nth ;

: doc-lines ( from to document -- slice )
    [ 1+ ] dip value>> <slice> ;

: start-on-line ( document from line# -- n1 )
    [ dup first ] dip = [ nip second ] [ 2drop 0 ] if ;

: end-on-line ( document to line# -- n2 )
    over first over = [
        drop second nip
    ] [
        nip swap doc-line length
    ] if ;

: each-line ( from to quot -- )
    2over = [
        3drop
    ] [
        [ [ first ] bi@ [a,b] ] dip each
    ] if ; inline

: start/end-on-line ( from to line# -- n1 n2 )
    tuck
    [ [ document get ] 2dip start-on-line ]
    [ [ document get ] 2dip end-on-line ]
    2bi* ;

: (doc-range) ( from to line# -- )
    [ start/end-on-line ] keep document get doc-line <slice> , ;

: doc-range ( from to document -- string )
    [
        document set 2dup [
            [ 2dup ] dip (doc-range)
        ] each-line 2drop
    ] { } make "\n" join ;

: text+loc ( lines loc -- loc )
    over [
        over length 1 = [
            nip first2
        ] [
            first swap length 1- + 0
        ] if
    ] dip peek length + 2array ;

: prepend-first ( str seq -- )
    0 swap [ append ] change-nth ;

: append-last ( str seq -- )
    [ length 1- ] keep [ prepend ] change-nth ;

: loc-col/str ( loc document -- str col )
    [ first2 swap ] dip nth swap ;

: prepare-insert ( newinput from to lines -- newinput )
    tuck [ loc-col/str head-slice ] [ loc-col/str tail-slice ] 2bi*
    pick append-last over prepend-first ;

: (set-doc-range) ( newlines from to lines -- )
    [ prepare-insert ] 3keep
    [ [ first ] bi@ 1+ ] dip
    replace-slice ;

: set-doc-range ( string from to document -- )
    [
        [ [ string-lines ] dip [ text+loc ] 2keep ] 2dip
        [ [ (set-doc-range) ] keep ] change-model
    ] keep update-locs ;

: change-doc-range ( from to document quot -- )
    '[ doc-range @ ] 3keep set-doc-range ; inline

: remove-doc-range ( from to document -- )
    [ "" ] 3dip set-doc-range ;

: last-line# ( document -- line )
    value>> length 1- ;

: validate-line ( line document -- line )
    last-line# min 0 max ;

: validate-col ( col line document -- col )
    doc-line length min 0 max ;

: line-end ( line# document -- loc )
    dupd doc-line length 2array ;

: line-end? ( loc document -- ? )
    [ first2 swap ] dip doc-line length = ;

: doc-end ( document -- loc )
    [ last-line# ] keep line-end ;

: validate-loc ( loc document -- newloc )
    over first over value>> length >= [
        nip doc-end
    ] [
        over first 0 < [
            2drop { 0 0 }
        ] [
            [ first2 swap tuck ] dip validate-col 2array
        ] if
    ] if ;

: doc-string ( document -- str )
    value>> "\n" join ;

: set-doc-string ( string document -- )
    [ string-lines V{ } like ] dip [ set-model ] keep
    [ doc-end ] [ update-locs ] bi ;

: clear-doc ( document -- )
    "" swap set-doc-string ;

GENERIC: prev-elt ( loc document elt -- newloc )
GENERIC: next-elt ( loc document elt -- newloc )

: prev/next-elt ( loc document elt -- start end )
    [ prev-elt ] [ next-elt ] 3bi ;

: elt-string ( loc document elt -- string )
    [ prev/next-elt ] [ drop ] 2bi doc-range ;

: set-elt-string ( string loc document elt -- )
    [ prev/next-elt ] [ drop ] 2bi set-doc-range ;

SINGLETON: char-elt

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

M: char-elt prev-elt
    drop [ drop -1 +col ] (prev-char) ;

M: char-elt next-elt
    drop [ drop 1 +col ] (next-char) ;

SINGLETON: one-char-elt

M: one-char-elt prev-elt 2drop ;

M: one-char-elt next-elt 2drop ;

: (word-elt) ( loc document quot -- loc )
    pick [
        [ [ first2 swap ] dip doc-line ] dip call
    ] dip =col ; inline

: ((word-elt)) ( n seq -- ? n seq ) [ ?nth blank? ] 2keep ;

: break-detector ( ? -- quot )
    '[ blank? _ xor ] ; inline

: (prev-word) ( ? col str -- col )
    rot break-detector find-last-from drop ?1+ ;

: (next-word) ( ? col str -- col )
    [ rot break-detector find-from drop ] keep
    over not [ nip length ] [ drop ] if ;

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
