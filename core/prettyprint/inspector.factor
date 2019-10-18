! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables io kernel assocs
math namespaces prettyprint sequences strings styles vectors
words quotations errors structure ;
IN: inspector

GENERIC: summary ( object -- string )

M: object summary
    "an instance of the " swap class word-name " class" 3append ;

M: input summary
    [
        "Input: " %
        input-string "\n" split1 swap %
        "..." "" ? %
    ] "" make ;

M: vocab-link summary
    [
        vocab-link-name dup %
        " vocabulary (" %
        words length #
        " words)" %
    ] "" make ;

M: sequence summary
    [ dup length # " element " % class word-name % ] "" make ;

M: hashtable summary
    "a hashtable storing " swap assoc-size number>string
    " keys" 3append ;

: value-editor ( path -- )
    [ pprint-short ] write-editable-object ;

: key-editor ( path -- )
    <key-path> value-editor ;

: describe-style
    H{
        { table-gap { 5 5 } }
        { table-border { 0.8 0.8 0.8 1.0 } }
    } ;

SYMBOL: +sequence+
SYMBOL: +number-rows+
SYMBOL: +editable+

: write-slot-editor ( path -- )
    [
        +editable+ get [
            [ pprint-short ] write-editable-object
        ] [
            field-path pprint-short
        ] if
    ] with-cell ;

: write-key ( obj key -- )
    +sequence+ get [
        2drop
    ] [
        2array <key-path> write-slot-editor
    ] if ;

: write-value ( obj key -- )
    2array write-slot-editor ;

: describe-row ( obj key n -- )
    [
        +number-rows+ get [ pprint-cell ] [ drop ] if
        2dup write-key write-value
    ] with-row ;

: summary. ( obj -- ) [ summary ] keep write-object nl ;

: describe* ( obj flags -- )
    clone [
        dup summary.
        dup sequence? +sequence+ set
        dup fields dup empty? [
            2drop
        ] [
            describe-style [
                dup length
                [ >r >r dup r> r> describe-row ] 2each drop
            ] tabular-output
        ] if
    ] bind ;

: describe ( obj -- ) H{ } describe* ;

SYMBOL: inspector-hook

[ H{ { +number-rows+ t } } describe* ] inspector-hook set-global

SYMBOL: inspector-stack

: me ( -- obj ) inspector-stack get peek ;

SYMBOL: me

: reinspect ( obj -- )
    dup me set
    dup fields \ fields set
    inspector-hook get call ;

: (inspect) ( obj -- )
    dup inspector-stack get push reinspect ;

: key@ ( n -- key ) \ fields get nth ;

: &push ( -- obj ) me get ;

: &at ( n -- ) key@ &push field (inspect) ;

: &back ( -- )
    inspector-stack get
    dup length 1 <= [ drop ] [ dup pop* peek reinspect ] if ;

: &add ( value key -- ) &push set-field &push reinspect ;

: &put ( value n -- ) key@ &add ;

: &delete ( n -- ) key@ &push delete-field &push reinspect ;

: &rename ( key n -- ) key@ &push rename-field &push reinspect ;

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
    "&help -- display this message" print
    nl ;

: inspector ( obj -- )
    &help
    V{ } clone inspector-stack set
    (inspect) ;

: inspect ( obj -- )
    inspector-stack get [ (inspect) ] [ inspector ] if ;
