! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: arrays generic io kernel math models namespaces sequences
strings test ;

: +col ( loc n -- loc ) >r first2 r> + 2array ;

: +line ( loc n -- loc ) >r first2 swap r> + swap 2array ;

: =col ( n loc -- loc ) first swap 2array ;

: =line ( n loc -- loc ) second 2array ;

: lines-equal? ( loc loc -- n ) [ first ] 2apply number= ;

TUPLE: document locs ;

C: document ( -- document )
    V{ "" } clone <model> over set-delegate
    V{ } clone over set-document-locs ;

: add-loc document-locs push ;

: remove-loc document-locs delete ;

: update-locs ( loc document -- )
    document-locs [ set-model* ] each-with ;

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

: (doc-range) ( startloc endloc line# -- )
    [ start/end-on-line ] keep document get doc-line <slice> , ;

: doc-range ( startloc endloc document -- str )
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

: prepare-insert ( newinput startloc endloc lines -- newinput )
    tuck loc-col/str tail-slice >r loc-col/str head-slice r>
    pick append-last over prepend-first ;

: (set-doc-range) ( newlines startloc endloc lines -- newlines )
    [ prepare-insert ] 3keep
    >r [ first ] 2apply 1+ r>
    replace-slice ;

: set-doc-range ( str startloc endloc document -- )
    [
        >r >r >r "\n" split r> [ text+loc ] 2keep r> r>
        [ (set-doc-range) ] change-model
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

: doc-text ( document -- str )
    model-value "\n" join ;

: set-doc-lines ( seq document -- )
    [ set-model ] keep dup doc-end swap update-locs ;

: set-doc-text ( string document -- )
    >r "\n" split r> set-doc-lines ;

: clear-doc ( document -- )
    "" swap set-doc-text ;
