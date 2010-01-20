! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic hashtables io kernel assocs math
namespaces prettyprint prettyprint.custom prettyprint.sections
sequences strings io.styles vectors words quotations mirrors
splitting math.parser classes vocabs sets sorting summary
debugger continuations fry combinators ;
IN: inspector

SYMBOL: +number-rows+

: print-summary ( obj -- ) [ summary ] keep write-object ;

<PRIVATE

: sort-unparsed-keys ( assoc -- alist )
    >alist dup keys
    [ unparse-short ] map
    zip sort-values keys ;

GENERIC: add-numbers ( alist -- table' )

M: enum add-numbers ;

M: assoc add-numbers
    +number-rows+ get [ [ prefix ] map-index ] when ;

TUPLE: slot-name name ;

M: slot-name pprint* name>> text ;

GENERIC: fix-slot-names ( assoc -- assoc )

M: assoc fix-slot-names >alist ;

M: mirror fix-slot-names
    [ [ slot-name boa ] dip ] { } assoc-map-as ;

: (describe) ( obj assoc -- keys )
    t pprint-string-cells? [
        [ print-summary nl ] [
            dup hashtable? [ sort-unparsed-keys ] when
            [ fix-slot-names add-numbers simple-table. ] [ keys ] bi
        ] bi*
    ] with-variable ;

PRIVATE>

: describe ( obj -- ) dup make-mirror (describe) drop ;

M: tuple error. describe ;

: vars-in-scope ( seq -- alist )
    [ [ global eq? not ] filter [ keys ] gather ] keep
    '[ dup _ assoc-stack ] H{ } map>assoc ;

: .vars ( -- )
    namestack vars-in-scope describe ;

: :vars ( -- )
    error-continuation get name>> vars-in-scope describe ;

SYMBOL: me

<PRIVATE

SYMBOL: inspector-stack

SYMBOL: sorted-keys

: reinspect ( obj -- )
    [ me set ]
    [
        dup make-mirror dup mirror set
        t +number-rows+ [ (describe) ] with-variable
        sorted-keys set
    ] bi ;

: (inspect) ( obj -- )
    [ inspector-stack get push ] [ reinspect ] bi ;

PRIVATE>

: key@ ( n -- key ) sorted-keys get nth ;

: &push ( -- obj ) me get ;

: &at ( n -- ) key@ mirror get at (inspect) ;

: &back ( -- )
    inspector-stack get
    dup length 1 <= [ drop ] [ [ pop* ] [ last reinspect ] bi ] if ;

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
