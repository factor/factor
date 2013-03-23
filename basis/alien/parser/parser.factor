! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries arrays
assocs classes combinators combinators.short-circuit
compiler.units effects grouping kernel parser sequences
splitting words fry locals lexer namespaces summary math
vocabs.parser words.constant classes.parser alien.enums ;
IN: alien.parser

SYMBOL: current-library

DEFER: (parse-c-type)

ERROR: bad-array-type ;

: parse-array-type ( name -- c-type )
    "[" split unclip
    [ [ "]" ?tail [ bad-array-type ] unless parse-datum ] map ]
    [ (parse-c-type) ]
    bi* prefix ;

: (parse-c-type) ( string -- type )
    {
        { [ "*" ?tail ] [ (parse-c-type) <pointer> ] }
        { [ CHAR: ] over member? ] [ parse-array-type ] }
        { [ dup search ] [ parse-word ] }
        [ parse-word ]
    } cond ;

: c-array? ( c-type -- ? )
    { [ array? ] [ first { [ c-type-word? ] [ pointer? ] } 1|| ] } 1&& ;

: valid-c-type? ( c-type -- ? )
    { [ c-array? ] [ c-type-word? ] [ pointer? ] [ void? ] } 1|| ;

: parse-c-type ( string -- type )
    (parse-c-type) dup valid-c-type? [ no-c-type ] unless ;

: scan-c-type ( -- c-type )
    scan-token {
        { [ dup "{" = ] [ drop \ } parse-until >array ] }
        { [ dup "pointer:" = ] [ drop scan-c-type <pointer> ] }
        [ parse-c-type ]
    } cond ; 

: reset-c-type ( word -- )
    dup "struct-size" word-prop
    [ dup [ forget-class ] [ { "struct-size" } reset-props ] bi ] when
    {
        "c-type"
        "callback-effect"
        "callback-library"
    } reset-props ;

ERROR: *-in-c-type-name name ;

: validate-c-type-name ( name -- name )
    dup "*" tail?
    [ *-in-c-type-name ] when ;

: (CREATE-C-TYPE) ( word -- word )
    validate-c-type-name current-vocab create {
        [ fake-definition ]
        [ set-last-word ]
        [ reset-c-type ]
        [ ]
    } cleave ;

: CREATE-C-TYPE ( -- word )
    scan-token (CREATE-C-TYPE) ;

<PRIVATE
GENERIC: return-type-name ( type -- name )

M: object return-type-name drop "void" ;
M: word return-type-name name>> ;
M: pointer return-type-name to>> return-type-name CHAR: * suffix ;

: parse-pointers ( type name -- type' name' )
    "*" ?head
    [ [ <pointer> ] dip parse-pointers ] when ;

: next-enum-member ( members name value -- members value' )
    [ define-enum-value ]
    [ [ 2array suffix! ] [ enum>number 1 + ] bi ] 2bi ;

: parse-enum-name ( -- name )
    CREATE-C-TYPE dup save-location ;

: parse-enum-base-type ( -- base-type token )
    scan-token dup "<" =
    [ drop scan-object scan-token ]
    [ [ int ] dip ] if ;

: parse-enum-member ( members name value -- members value' )
    over "{" =
    [ 2drop scan-token create-class-in scan-object next-enum-member "}" expect ]
    [ [ create-class-in ] dip next-enum-member ] if ;

: parse-enum-members ( members counter token -- members )
    dup ";" = not
    [ swap parse-enum-member scan-token parse-enum-members ] [ 2drop ] if ;

PRIVATE>

: parse-enum ( -- name base-type members )
    parse-enum-name
    parse-enum-base-type
    [ V{ } clone 0 ] dip parse-enum-members ;

: scan-function-name ( -- return function )
    scan-c-type scan-token parse-pointers ;

:: (scan-c-args) ( end-marker types names -- )
    scan-token :> type-str
    type-str end-marker = [
        type-str { "(" ")" } member? [
            type-str parse-c-type :> type
            scan-token "," ?tail drop :> name
            type name parse-pointers :> ( type' name' )
            type' types push name' names push
        ] unless
        end-marker types names (scan-c-args)
    ] unless ;

: scan-c-args ( end-marker -- types names )
    V{ } clone V{ } clone [ (scan-c-args) ] 2keep [ >array ] bi@ ;

: function-quot ( return library function types -- quot )
    '[ _ _ _ _ alien-invoke ] ;

: function-effect ( names return -- effect )
    [ { } ] [ return-type-name 1array ] if-void <effect> ;

: create-function ( name -- word )
    create-in dup reset-generic ;

:: (make-function) ( return function library types names -- quot effect )
    return library function types function-quot
    names return function-effect ;

:: make-function ( return function library types names -- word quot effect )
    function create-function
    return function library types names (make-function) ;

: (FUNCTION:) ( -- return function library types names )
    scan-function-name current-library get ";" scan-c-args ;

: callback-quot ( return types abi -- quot )
    '[ [ _ _ _ ] dip alien-callback ] ;

:: make-callback-type ( lib return type-name types names -- word quot effect )
    type-name current-vocab create :> type-word 
    type-word [ reset-generic ] [ reset-c-type ] bi
    void* type-word typedef
    type-word names return function-effect "callback-effect" set-word-prop
    type-word lib "callback-library" set-word-prop
    type-word return types lib library-abi callback-quot ( quot -- alien ) ;

: (CALLBACK:) ( -- word quot effect )
    current-library get
    scan-function-name ";" scan-c-args make-callback-type ;

PREDICATE: alien-function-alias-word < word
    def>> {
        [ length 5 = ]
        [ last \ alien-invoke eq? ]
    } 1&& ;

PREDICATE: alien-function-word < alien-function-alias-word
    [ def>> third ] [ name>> ] bi = ;

PREDICATE: alien-callback-type-word < typedef-word
    "callback-effect" word-prop >boolean ;

: global-quot ( type word -- quot )
    swap [ name>> current-library get ] dip
    '[ _ _ address-of 0 _ alien-value ] ;

: set-global-quot ( type word -- quot )
    swap [ name>> current-library get ] dip
    '[ _ _ address-of 0 _ set-alien-value ] ;

: define-global-getter ( type word -- )
    [ nip ] [ global-quot ] 2bi ( -- value ) define-declared ;

: define-global-setter ( type word -- )
    [ nip name>> "set-" prepend create-in ]
    [ set-global-quot ] 2bi ( obj -- ) define-declared ;

: define-global ( type word -- )
    [ define-global-getter ] [ define-global-setter ] 2bi ;
