! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: arrays generic io kernel math models namespaces sequences
test ;

: +col ( loc n -- loc ) >r first2 r> + 2array ;

: +line ( loc n -- loc ) >r first2 swap r> + swap 2array ;

: =col ( n loc -- loc ) first swap 2array ;

: =line ( n loc -- loc ) second 2array ;

: lines-equal? ( loc loc -- n ) [ first ] 2apply number= ;

TUPLE: document locs ;

C: document ( -- document )
    { "" } <history> over set-delegate
    V{ } clone over set-document-locs ;

: add-loc document-locs push ;

: remove-loc document-locs delete ;

: update-locs ( loc document -- )
    document-locs [ set-model ] each-with ;

: doc-line ( line# document -- str ) model-value nth ;

: doc-lines ( from# to# document -- slice )
    >r 1+ r> model-value <slice> ;

: start-on-line ( document from line# -- n1 )
    >r dup first r> = [ nip second ] [ 2drop 0 ] if ;

: end-on-line ( document to line# -- n2 )
    over first over = [
        drop second nip
    ] [
        nip swap doc-line length
    ] if ;

: each-line ( startloc endloc quot -- )
    pick pick = [
        3drop
    ] [
        >r [ first ] 2apply 1+ dup <slice> r> each
    ] if ; inline

: start/end-on-line ( startloc endloc line# -- n1 n2 )
    tuck >r >r document get -rot start-on-line r> r>
    document get -rot end-on-line ;

: (doc-range) ( startloc endloc line# -- str )
    [ start/end-on-line ] keep document get doc-line <slice> , ;

: doc-range ( startloc endloc document -- str )
    [
        document set 2dup [
            >r 2dup r> (doc-range)
        ] each-line 2drop
    ] { } make "\n" join ;

: replace-columns ( str start# end# line# document -- )
    [
        [ swap [ replace-slice ] change-nth ] keep
    ] change-model ;

: set-on-1 ( lines startloc endloc document -- )
    >r >r >r first r> second r> first2 swap r> replace-columns ;

: loc-col/str ( loc lines -- col str )
    >r first2 swap r> nth ;

: merge-lines ( lines startloc endloc lines -- str )
    #! Start line from 0 to start col + end line from end col
    #! to length
    tuck loc-col/str tail-slice
    >r loc-col/str head-slice
    swap first r> append3 ;

: set-on>1pre ( str startloc endloc lines -- )
    [ merge-lines 1array ] 3keep
    >r [ first ] 2apply 1+ r> replace-slice ;

: set-on>1 ( str startloc endloc document -- )
    [ set-on>1pre ] change-model ;

: text+loc ( lines loc -- loc )
    over >r over length 1 = [
        nip first2
    ] [
        first swap length 1- + 0
    ] if r> peek length + 2array ;

: set-doc-range ( str startloc endloc document -- )
    [
        >r >r >r "\n" split r> [ text+loc ] 2keep r> r>
        pick pick lines-equal? [ set-on-1 ] [ set-on>1 ] if
    ] keep update-locs ;

: remove-doc-range ( startloc endloc document -- )
    >r >r >r "" r> r> r> set-doc-range ;

: validate-line ( line document -- line )
    model-value length 1- min 0 max ;

: validate-col ( col line document -- col )
    doc-line length min 0 max ;

: validate-loc ( loc document -- loc )
    >r first2 swap r> [ validate-line ] keep
    >r tuck r> validate-col 2array ;

: line-end ( line# document -- loc )
    dupd doc-line length 2array ;

: line-end? ( loc document -- ? )
    >r first2 swap r> doc-line length = ;

: doc-end ( document -- loc )
    model-value dup length 1- swap peek length 2array ;

GENERIC: prev-elt ( loc document elt -- loc )
GENERIC: next-elt ( loc document elt -- loc )

TUPLE: char-elt ;

M: char-elt prev-elt
    drop {
        { [ over { 0 0 } = ] [ drop ] }
        { [ over second zero? ] [ >r first 1- r> line-end ] }
        { [ t ] [ drop -1 +col ] }
    } cond ;

M: char-elt next-elt
    drop {
        { [ 2dup doc-end = ] [ drop ] }
        { [ 2dup line-end? ] [ drop first 1+ 0 2array ] }
        { [ t ] [ drop 1 +col ] }
    } cond ;

TUPLE: line-elt ;

M: line-elt prev-elt 2drop -1 +line ;
M: line-elt next-elt 2drop 1 +line ;

: doc-text ( document -- str )
    model-value "\n" join ;

: set-doc-text ( string document -- )
    [ >r "\n" split r> set-model ] keep
    dup doc-end swap update-locs ;

: clear-doc ( document -- )
    "" swap set-doc-text ;
