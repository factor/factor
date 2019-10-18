! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables io kernel assocs math
namespaces prettyprint sequences strings io.styles vectors words
quotations mirrors splitting math.parser classes vocabs refs ;
IN: inspector

GENERIC: summary ( object -- string )

: object-summary ( object -- string )
    class word-name " instance" append ;

M: object summary object-summary ;

M: input summary
    [
        "Input: " %
        input-string "\n" split1 swap %
        "..." "" ? %
    ] "" make ;

M: word summary synopsis ;

M: sequence summary
    [
        dup class word-name %
        " with " %
        length #
        " elements" %
    ] "" make ;

M: assoc summary
    [
        dup class word-name %
        " with " %
        assoc-size #
        " entries" %
    ] "" make ;

! Override sequence => integer instance
M: f summary object-summary ;

M: integer summary object-summary ;

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

: describe-row ( obj key n -- )
    [
        +number-rows+ get [ pprint-cell ] [ drop ] if
        2dup write-key write-value
    ] with-row ;

: summary. ( obj -- ) [ summary ] keep write-object nl ;

: describe* ( obj flags -- )
    clone [
        dup summary.
        make-mirror dup keys dup empty? [
            2drop
        ] [
            dup enum? [ +sequence+ on ] when
            standard-table-style [
                dup length
                rot [ -rot describe-row ] curry 2each
            ] tabular-output
        ] if
    ] bind ;

: describe ( obj -- ) H{ } describe* ;

SYMBOL: inspector-hook

[ H{ { +number-rows+ t } } describe* ] inspector-hook set-global

SYMBOL: inspector-stack

SYMBOL: me

: reinspect ( obj -- )
    dup me set
    dup make-mirror dup mirror set keys \ keys set
    inspector-hook get call ;

: (inspect) ( obj -- )
    dup inspector-stack get push reinspect ;

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
    "&help -- display this message" print
    nl ;

: inspector ( obj -- )
    &help
    V{ } clone inspector-stack set
    (inspect) ;

: inspect ( obj -- )
    inspector-stack get [ (inspect) ] [ inspector ] if ;
