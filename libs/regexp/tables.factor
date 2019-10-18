USING: errors generic hashtables kernel namespaces
sequences vectors ;
IN: tables

TUPLE: table rows columns ;
TUPLE: entry row-key column-key value ;
GENERIC: add-value ( entry table -- )

C: table ( -- obj )
	H{ } clone over set-table-rows
	H{ } clone over set-table-columns ;

: (add-row) ( row-key table -- row )
	2dup table-rows hash* [
        2nip
	] [
		drop H{ } clone [ -rot table-rows set-hash ] keep
	] if ;

: add-row ( row-key table -- )
    (add-row) drop ;

: add-column ( column-key table -- )
	t -rot table-columns set-hash ;

: set-row ( row row-key table -- )
	table-rows set-hash ;

: lookup-row ( row-key table -- row/f ? )
    table-rows hash* ;

: row-exists? ( row-key table -- ? )
    lookup-row nip ;

: lookup-column ( column-key table -- column/f ? )
    table-columns hash* ;

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
        hash*
    ] [
        2drop f f
    ] if ;

: (set-value) ( entry table -- value column-key row )
    [ >r entry-column-key r> add-column ] 2keep
    dupd >r entry-row-key r> (add-row)
    >r [ entry-value ] keep entry-column-key r> ;

: set-value ( entry table -- )
    (set-value) set-hash ;
    
: swap-rows ( row-key1 row-key2 table -- )
	[ tuck get-row >r get-row r> ] 3keep
	>r >r rot r> r> [ set-row ] keep set-row ;

: member?* ( obj obj -- bool )
    2dup = [ 2drop t ] [ member? ] if ;

: find-by-column ( column-key data table -- seq )
    swapd 2dup lookup-column 2drop 
    [
        table-rows [
            pick swap hash* [ 
                >r pick r> member?* [ , ] [ drop ] if
            ] [ 
                2drop
            ] if 
        ] hash-each
    ] { } make 2nip ;

    
TUPLE: vector-table ;
C: vector-table ( -- obj )
    <table> over set-delegate ;

: add-hash-vector ( value key hash -- )
    2dup hash* [
        dup vector? [
            2nip push
        ] [
            V{ } clone [ push ] keep
            -rot >r >r [ push ] keep r> r> set-hash
        ] if
    ] [
        drop set-hash
    ] if ;
 
M: vector-table add-value ( entry table -- )
    (set-value) add-hash-vector ;

