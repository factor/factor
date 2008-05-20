! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces sequences vectors assocs accessors ;
IN: state-tables

TUPLE: table rows columns start-state final-states ;
TUPLE: entry row-key column-key value ;

GENERIC: add-entry ( entry table -- )

: make-table ( class -- obj )
    new
        H{ } clone >>rows
        H{ } clone >>columns
        H{ } clone >>final-states ;

: <table> ( -- obj )
    table make-table ;

C: <entry> entry

: (add-row) ( row-key table -- row )
    2dup rows>> at* [
        2nip
    ] [
        drop H{ } clone [ -rot rows>> set-at ] keep
    ] if ;

: add-row ( row-key table -- )
    (add-row) drop ;

: add-column ( column-key table -- )
    t -rot columns>> set-at ;

: set-row ( row row-key table -- )
    rows>> set-at ;

: lookup-row ( row-key table -- row/f ? )
    rows>> at* ;

: row-exists? ( row-key table -- ? )
    lookup-row nip ;

: lookup-column ( column-key table -- column/f ? )
    columns>> at* ;

: column-exists? ( column-key table -- ? )
    lookup-column nip ;

ERROR: no-row key ;
ERROR: no-column key ;

: get-row ( row-key table -- row )
    dupd lookup-row [
        nip
    ] [
        drop no-row
    ] if ;

: get-column ( column-key table -- column )
    dupd lookup-column [
        nip
    ] [
        drop no-column
    ] if ;

: get-entry ( row-key column-key table -- obj ? )
    swapd lookup-row [
        at*
    ] [
        2drop f f
    ] if ;

: (set-entry) ( entry table -- value column-key row )
    [ >r column-key>> r> add-column ] 2keep
    dupd >r row-key>> r> (add-row)
    >r [ value>> ] keep column-key>> r> ;

: set-entry ( entry table -- )
    (set-entry) set-at ;

: delete-entry ( entry table -- )
    >r [ column-key>> ] [ row-key>> ] bi r>
    lookup-row [ delete-at ] [ 2drop ] if ;

: swap-rows ( row-key1 row-key2 table -- )
    [ tuck get-row >r get-row r> ] 3keep
    >r >r rot r> r> [ set-row ] keep set-row ;

: member?* ( obj obj -- bool )
    2dup = [ 2drop t ] [ member? ] if ;

: find-by-column ( column-key data table -- seq )
    swapd 2dup lookup-column 2drop 
    [
        rows>> [
            pick swap at* [ 
                >r pick r> member?* [ , ] [ drop ] if
            ] [ 
                2drop
            ] if 
        ] assoc-each
    ] { } make 2nip ;


TUPLE: vector-table < table ;
: <vector-table> ( -- obj )
    vector-table make-table ;

: add-hash-vector ( value key hash -- )
    2dup at* [
        dup vector? [
            2nip push
        ] [
            V{ } clone [ push ] keep
            -rot >r >r [ push ] keep r> r> set-at
        ] if
    ] [
        drop set-at
    ] if ;
 
M: vector-table add-entry ( entry table -- )
    (set-entry) add-hash-vector ;
