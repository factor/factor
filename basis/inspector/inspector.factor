! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic hashtables io kernel assocs math
namespaces prettyprint sequences strings io.styles vectors words
quotations mirrors splitting math.parser classes vocabs refs
sets sorting summary debugger continuations fry ;
IN: inspector

: value-editor ( path -- )
    [
        [ pprint-short ] presented-printer set
        dup presented-path set
    ] H{ } make-assoc
    [ get-ref pprint-short ] with-nesting ;

SYMBOL: +sequence+
SYMBOL: +number-rows+
SYMBOL: +editable+

: write-slot-editor ( path -- )
    [
        +editable+ get [
            value-editor
        ] [
            get-ref pprint-short
        ] if
    ] with-cell ;

: write-key ( mirror key -- )
    +sequence+ get
    [ 2drop ] [ <key-ref> write-slot-editor ] if ;

: write-value ( mirror key -- )
    <value-ref> write-slot-editor ;

: describe-row ( mirror key n -- )
    [
        +number-rows+ get [ pprint-cell ] [ drop ] if
        [ write-key ] [ write-value ] 2bi
    ] with-row ;

: summary. ( obj -- ) [ summary ] keep write-object nl ;

: sorted-keys ( assoc -- alist )
    dup hashtable? [
        keys
        [ [ unparse-short ] keep ] { } map>assoc
        sort-keys values
    ] [ keys ] if ;

: describe* ( obj mirror keys -- )
    [ summary. ] 2dip
    [ drop ] [
        dup enum? [ +sequence+ on ] when
        standard-table-style [
            swap '[ [ _ ] 2dip describe-row ] each-index
        ] tabular-output
    ] if-empty ;

: describe ( obj -- )
    dup make-mirror dup sorted-keys describe* ;

M: tuple error. describe ;

: namestack. ( seq -- )
    [ [ global eq? not ] filter [ keys ] gather ] keep
    '[ dup _ assoc-stack ] H{ } map>assoc describe ;

: .vars ( -- )
    namestack namestack. ;

: :vars ( -- )
    error-continuation get name>> namestack. ;

SYMBOL: inspector-hook

[ t +number-rows+ [ describe* ] with-variable ] inspector-hook set-global

SYMBOL: inspector-stack

SYMBOL: me

: reinspect ( obj -- )
    [ me set ]
    [
        dup make-mirror dup mirror set dup sorted-keys dup \ keys set
        inspector-hook get call
    ] bi ;

: (inspect) ( obj -- )
    [ inspector-stack get push ] [ reinspect ] bi ;

: key@ ( n -- key ) \ keys get nth ;

: &push ( -- obj ) me get ;

: &at ( n -- ) key@ mirror get at (inspect) ;

: &back ( -- )
    inspector-stack get
    dup length 1 <= [ drop ] [ dup pop* peek reinspect ] if ;

: &add ( value key -- ) mirror get set-at &push reinspect ;

: &put ( value n -- ) key@ &add ;

: &delete ( n -- ) key@ mirror get delete-at &push reinspect ;

: &rename ( key n -- ) key@ mirror get rename-at &push reinspect ;

: &help ( -- )
    #! A tribute to Slate:
    "You are in a twisty little maze of objects, all alike." print
    nl
    "'n' is a slot number in the following:" print
    nl
    "&back -- return to previous object" print
    "&push ( -- obj ) push this object" print
    "&at ( n -- ) inspect nth slot" print
    "&put ( value n -- ) change nth slot" print
    "&add ( value key -- ) add new slot" print
    "&delete ( n -- ) remove a slot" print
    "&rename ( key n -- ) change a slot's key" print
    "&globals ( -- ) inspect global namespace" print
    "&help -- display this message" print
    nl ;

: inspector ( obj -- )
    &help
    V{ } clone inspector-stack set
    (inspect) ;

: inspect ( obj -- )
    inspector-stack get [ (inspect) ] [ inspector ] if ;

: &globals ( -- ) global inspect ;
