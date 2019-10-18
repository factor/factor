! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io kernel math models namespaces sequences strings
splitting io.streams.lines combinators ;
IN: documents

: +col ( loc n -- newloc ) >r first2 r> + 2array ;

: +line ( loc n -- newloc ) >r first2 swap r> + swap 2array ;

: =col ( n loc -- newloc ) first swap 2array ;

: =line ( n loc -- newloc ) second 2array ;

: lines-equal? ( loc1 loc2 -- ? ) [ first ] 2apply number= ;

TUPLE: document locs ;

: <document> ( -- document )
    V{ "" } clone <model> V{ } clone
    { set-delegate set-document-locs } document construct ;

: add-loc document-locs push ;

: remove-loc document-locs delete ;

: update-locs ( loc document -- )
    document-locs [ set-model ] curry* each ;

: doc-line ( n document -- string ) model-value nth ;

: doc-lines ( from to document -- slice )
    >r 1+ r> model-value <slice> ;

: start-on-line ( document from line# -- n1 )
    >r dup first r> = [ nip second ] [ 2drop 0 ] if ;

: end-on-line ( document to line# -- n2 )
    over first over = [
        drop second nip
    ] [
        nip swap doc-line length
    ] if ;

: each-line ( from to quot -- )
    pick pick = [
        3drop
    ] [
        >r [ first ] 2apply 1+ dup <slice> r> each
    ] if ; inline

: start/end-on-line ( from to line# -- n1 n2 )
    tuck >r >r document get -rot start-on-line r> r>
    document get -rot end-on-line ;

: (doc-range) ( from to line# -- )
    [ start/end-on-line ] keep document get doc-line <slice> , ;

: doc-range ( from to document -- string )
    [
        document set 2dup [
            >r 2dup r> (doc-range)
        ] each-line 2drop
    ] { } make "\n" join ;

: text+loc ( lines loc -- loc )
    over >r over length 1 = [
        nip first2
    ] [
        first swap length 1- + 0
    ] if r> peek length + 2array ;

: prepend-first ( str seq -- )
    0 swap [ append ] change-nth ;

: append-last ( str seq -- )
    [ length 1- ] keep [ swap append ] change-nth ;

: loc-col/str ( loc document -- str col )
    >r first2 swap r> nth swap ;

: prepare-insert ( newinput from to lines -- newinput )
    tuck loc-col/str tail-slice >r loc-col/str head-slice r>
    pick append-last over prepend-first ;

: (set-doc-range) ( newlines from to lines -- )
    [ prepare-insert ] 3keep
    >r [ first ] 2apply 1+ r>
    replace-slice ;

: set-doc-range ( string from to document -- )
    [
        >r >r >r string-lines r> [ text+loc ] 2keep r> r>
        [ [ (set-doc-range) ] keep ] change-model
    ] keep update-locs ;

: remove-doc-range ( from to document -- )
    >r >r >r "" r> r> r> set-doc-range ;

: last-line# ( document -- line )
    model-value length 1- ;

: validate-line ( line document -- line )
    last-line# min 0 max ;

: validate-col ( col line document -- col )
    doc-line length min 0 max ;

: line-end ( line# document -- loc )
    dupd doc-line length 2array ;

: line-end? ( loc document -- ? )
    >r first2 swap r> doc-line length = ;

: doc-end ( document -- loc )
    [ last-line# ] keep line-end ;

: validate-loc ( loc document -- newloc )
    over first over model-value length >= [
        nip doc-end
    ] [
        over first 0 < [
            2drop { 0 0 }
        ] [
            >r first2 swap tuck r> validate-col 2array
        ] if
    ] if ;

: doc-string ( document -- str )
    model-value "\n" join ;

: set-doc-string ( string document -- )
    >r string-lines V{ } like r> [ set-model ] keep
    dup doc-end swap update-locs ;

: clear-doc ( document -- )
    "" swap set-doc-string ;

GENERIC: prev-elt ( loc document elt -- newloc )
GENERIC: next-elt ( loc document elt -- newloc )

: prev/next-elt ( loc document elt -- start end )
    3dup next-elt >r prev-elt r> ;

: elt-string ( loc document elt -- string )
    over >r prev/next-elt r> doc-range ;

TUPLE: char-elt ;

: (prev-char) ( loc document quot -- loc )
    -rot {
        { [ over { 0 0 } = ] [ drop ] }
        { [ over second zero? ] [ >r first 1- r> line-end ] }
        { [ t ] [ pick call ] }
    } cond nip ; inline

: (next-char) ( loc document quot -- loc )
    -rot {
        { [ 2dup doc-end = ] [ drop ] }
        { [ 2dup line-end? ] [ drop first 1+ 0 2array ] }
        { [ t ] [ pick call ] }
    } cond nip ; inline

M: char-elt prev-elt
    drop [ drop -1 +col ] (prev-char) ;

M: char-elt next-elt
    drop [ drop 1 +col ] (next-char) ;

: (word-elt) ( loc document quot -- loc )
    pick >r
    >r >r first2 swap r> doc-line r> call
    r> =col ; inline

: ((word-elt)) [ ?nth blank? ] 2keep ;

: break-detector ( ? -- quot )
    [ >r blank? r> xor ] curry ; inline

: (prev-word) ( ? col str -- col )
    rot break-detector find-last*
    drop [ 1+ ] [ 0 ] if* ;

: (next-word) ( ? col str -- col )
    [ rot break-detector find* drop ] keep
    over not [ nip length ] [ drop ] if ;

TUPLE: one-word-elt ;

M: one-word-elt prev-elt
    drop
    [ [ f -rot >r 1- r> (prev-word) ] (word-elt) ] (prev-char) ;

M: one-word-elt next-elt
    drop
    [ [ f -rot (next-word) ] (word-elt) ] (next-char) ;

TUPLE: word-elt ;

M: word-elt prev-elt
    drop
    [ [ >r 1- r> ((word-elt)) (prev-word) ] (word-elt) ]
    (prev-char) ;

M: word-elt next-elt
    drop
    [ [ ((word-elt)) (next-word) ] (word-elt) ]
    (next-char) ;

TUPLE: one-line-elt ;

M: one-line-elt prev-elt
    2drop first 0 2array ;

M: one-line-elt next-elt
    drop >r first dup r> doc-line length 2array ;

TUPLE: line-elt ;

M: line-elt prev-elt
    2drop dup first zero? [ drop { 0 0 } ] [ -1 +line ] if ;

M: line-elt next-elt
    drop over first over last-line# number=
    [ nip doc-end ] [ drop 1 +line ] if ;

TUPLE: doc-elt ;

M: doc-elt prev-elt 3drop { 0 0 } ;

M: doc-elt next-elt drop nip doc-end ;
