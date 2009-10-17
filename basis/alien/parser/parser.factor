! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.parser
alien.libraries arrays assocs classes combinators
combinators.short-circuit compiler.units effects grouping
kernel parser sequences splitting words fry locals lexer
namespaces summary math vocabs.parser ;
IN: alien.parser

: parse-c-type-name ( name -- word )
    dup search [ ] [ no-word ] ?if ;

: parse-array-type ( name -- dims c-type )
    "[" split unclip
    [ [ "]" ?tail drop parse-word ] map ] dip ;

: (parse-c-type) ( string -- type )
    {
        { [ dup "void" =         ] [ drop void ] }
        { [ CHAR: ] over member? ] [ parse-array-type parse-c-type-name prefix ] }
        { [ dup search           ] [ parse-c-type-name ] }
        { [ "**" ?tail           ] [ drop void* ] }
        { [ "*" ?tail            ] [ parse-c-type-name resolve-pointer-type ] }
        [ dup search [ ] [ no-word ] ?if ]
    } cond ;

: valid-c-type? ( c-type -- ? )
    { [ array? ] [ c-type-name? ] [ void? ] } 1|| ;

: parse-c-type ( string -- type )
    (parse-c-type) dup valid-c-type? [ no-c-type ] unless ;

: scan-c-type ( -- c-type )
    scan dup "{" =
    [ drop \ } parse-until >array ]
    [ parse-c-type ] if ; 

: reset-c-type ( word -- )
    dup "struct-size" word-prop
    [ dup [ forget-class ] [ { "struct-size" } reset-props ] bi ] when
    {
        "c-type"
        "pointer-c-type"
        "callback-effect"
        "callback-library"
    } reset-props ;

: CREATE-C-TYPE ( -- word )
    scan current-vocab create {
        [ fake-definition ]
        [ set-word ]
        [ reset-c-type ]
        [ ]
    } cleave ;

: normalize-c-arg ( type name -- type' name' )
    [ length ]
    [
        [ CHAR: * = ] trim-head
        [ length - CHAR: * <array> append ] keep
    ] bi
    [ parse-c-type ] dip ;

: parse-arglist ( parameters return -- types effect )
    [
        2 group [ first2 normalize-c-arg 2array ] map
        unzip [ "," ?tail drop ] map
    ]
    [ [ { } ] [ 1array ] if-void ]
    bi* <effect> ;

: function-quot ( return library function types -- quot )
    '[ _ _ _ _ alien-invoke ] ;

:: make-function ( return! library function! parameters -- word quot effect )
    return function normalize-c-arg function! return!
    function create-in dup reset-generic
    return library function
    parameters return parse-arglist [ function-quot ] dip ;

: parse-arg-tokens ( -- tokens )
    ";" parse-tokens [ "()" subseq? not ] filter ;

: (FUNCTION:) ( -- word quot effect )
    scan "c-library" get scan parse-arg-tokens make-function ;

: define-function ( return library function parameters -- )
    make-function define-declared ;

: callback-quot ( return types abi -- quot )
    [ [ ] 3curry dip alien-callback ] 3curry ;

: library-abi ( lib -- abi )
    library [ abi>> ] [ "cdecl" ] if* ;

:: make-callback-type ( lib return! type-name! parameters -- word quot effect )
    return type-name normalize-c-arg type-name! return!
    type-name current-vocab create :> type-word 
    type-word [ reset-generic ] [ reset-c-type ] bi
    void* type-word typedef
    parameters return parse-arglist :> callback-effect :> types
    type-word callback-effect "callback-effect" set-word-prop
    type-word lib "callback-library" set-word-prop
    type-word return types lib library-abi callback-quot (( quot -- alien )) ;

: (CALLBACK:) ( -- word quot effect )
    "c-library" get
    scan scan parse-arg-tokens make-callback-type ;

PREDICATE: alien-function-word < word
    def>> {
        [ length 5 = ]
        [ last \ alien-invoke eq? ]
    } 1&& ;

PREDICATE: alien-callback-type-word < typedef-word
    "callback-effect" word-prop ;

