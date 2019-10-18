USING: errors generic kernel namespaces
sequences vectors assocs ;
IN: tables

TUPLE: table rows columns ;
TUPLE: entry row-key column-key value ;
GENERIC: add-value ( entry table -- )

C: table ( -- obj )
	H{ } clone over set-table-rows
	H{ } clone over set-table-columns ;

: (add-row) ( row-key table -- row )
	2dup table-rows at* [
        2nip
	] [
		drop H{ } clone [ -rot table-rows set-at ] keep
	] if ;

: add-row ( row-key table -- )
    (add-row) drop ;

: add-column ( column-key table -- )
	t -rot table-columns set-at ;

: set-row ( row row-key table -- )
	table-rows set-at ;

: lookup-row ( row-key table -- row/f ? )
    table-rows at* ;

: row-exists? ( row-key table -- ? )
    lookup-row nip ;

: lookup-column ( column-key table -- column/f ? )
    table-columns at* ;

: column-exists? ( column-key table -- ? )
    lookup-column nip ;

TUPLE: no-row key ;
TUPLE: no-column key ;

: get-row ( row-key table -- row )
    dupd lookup-row [
        nip
    ] [
        drop <no-row> throw
    ] if ;

: get-column ( column-key table -- column )
    dupd lookup-column [
        nip
    ] [
        drop <no-column> throw
    ] if ;

: get-value ( row-key column-key table -- obj ? )
    swapd lookup-row [
        at*
    ] [
        2drop f f
    ] if ;

: (set-value) ( entry table -- value column-key row )
    [ >r entry-column-key r> add-column ] 2keep
    dupd >r entry-row-key r> (add-row)
    >r [ entry-value ] keep entry-column-key r> ;

: set-value ( entry table -- )
    (set-value) set-at ;
    
: swap-rows ( row-key1 row-key2 table -- )
	[ tuck get-row >r get-row r> ] 3keep
	>r >r rot r> r> [ set-row ] keep set-row ;

: member?* ( obj obj -- bool )
    2dup = [ 2drop t ] [ member? ] if ;

: find-by-column ( column-key data table -- seq )
    swapd 2dup lookup-column 2drop 
    [
        table-rows [
            pick swap at* [ 
                >r pick r> member?* [ , ] [ drop ] if
            ] [ 
                2drop
            ] if 
        ] assoc-each
    ] { } make 2nip ;

    
TUPLE: vector-table ;
C: vector-table ( -- obj )
    <table> over set-delegate ;

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
 
M: vector-table add-value ( entry table -- )
    (set-value) add-hash-vector ;

