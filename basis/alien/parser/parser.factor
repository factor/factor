! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs
combinators combinators.short-circuit effects grouping
kernel parser sequences splitting words fry locals lexer
namespaces summary math vocabs.parser ;
IN: alien.parser

: parse-c-type-name ( name -- word/string )
    [ search ] keep or ;

: parse-c-type ( string -- array )
    {
        { [ dup "void" =            ] [ drop void ] }
        { [ CHAR: ] over member?    ] [ parse-array-type parse-c-type-name prefix ] }
        { [ dup search c-type-word? ] [ parse-c-type-name ] }
        { [ dup c-types get at      ] [ ] }
        { [ "*" ?tail               ] [ parse-c-type-name resolve-pointer-type ] }
        [ no-c-type ]
    } cond ;

: scan-c-type ( -- c-type )
    scan dup "{" =
    [ drop \ } parse-until >array ]
    [ parse-c-type ] if ; 

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

: (FUNCTION:) ( -- word quot effect )
    scan "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] filter
    make-function ;

: define-function ( return library function parameters -- )
    make-function define-declared ;

PREDICATE: alien-function-word < word
    def>> {
        [ length 5 = ]
        [ last \ alien-invoke eq? ]
    } 1&& ;
