! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs
combinators combinators.short-circuit effects grouping
kernel parser sequences splitting words fry locals lexer
namespaces summary math vocabs.parser ;
IN: alien.parser

: parse-c-type-name ( name -- word )
    dup search [ nip ] [ no-word ] if* ;

: parse-c-type ( string -- array )
    {
        { [ dup "void" =            ] [ drop void ] }
        { [ CHAR: ] over member?    ] [ parse-array-type parse-c-type-name prefix ] }
        { [ dup search c-type-word? ] [ parse-c-type-name ] }
        { [ "**" ?tail              ] [ drop void* ] }
        { [ "*" ?tail               ] [ parse-c-type-name resolve-pointer-type ] }
        [ parse-c-type-name no-c-type ]
    } cond ;

: scan-c-type ( -- c-type )
    scan dup "{" =
    [ drop \ } parse-until >array ]
    [ parse-c-type ] if ; 

: reset-c-type ( word -- )
    { "c-type" "pointer-c-type" "callback-effect" "callback-abi" } reset-props ;

: CREATE-C-TYPE ( -- word )
    scan current-vocab create dup reset-c-type ;

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

:: make-callback-type ( abi return! type-name! parameters -- word quot effect )
    return type-name normalize-c-arg type-name! return!
    type-name current-vocab create :> type-word 
    type-word [ reset-generic ] [ reset-c-type ] bi
    void* type-word typedef
    parameters return parse-arglist :> callback-effect :> types
    type-word callback-effect "callback-effect" set-word-prop
    type-word abi "callback-abi" set-word-prop
    type-word return types abi callback-quot (( quot -- alien )) ;

: (CALLBACK:) ( abi -- word quot effect )
    scan scan parse-arg-tokens make-callback-type ;

PREDICATE: alien-function-word < word
    def>> {
        [ length 5 = ]
        [ last \ alien-invoke eq? ]
    } 1&& ;

PREDICATE: alien-callback-type-word < typedef-word
    "callback-effect" word-prop ;

