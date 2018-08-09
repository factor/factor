! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators kernel namespaces sequences splitting
strings strings.parser ;
IN: syntax.modern

INITIALIZED-SYMBOL: single-quote-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: lower-colon-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: upper-colon-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: double-quote-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: bracket-container-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: brace-container-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: paren-container-definitions [ H{ } clone ]

: define-single-quote-word ( word def -- ) swap lower-colon-definitions get set-at ;
: define-lower-colon-word ( word def -- ) swap lower-colon-definitions get set-at ;
: define-upper-colon-word ( word def -- ) swap upper-colon-definitions get set-at ;
: define-double-quote-word ( word def -- ) swap double-quote-definitions get set-at ;
: define-bracket-container-word ( word def -- ) swap bracket-container-definitions get set-at ;
: define-brace-container-word ( word def -- ) swap brace-container-definitions get set-at ;
: define-paren-container-word ( word def -- ) swap paren-container-definitions get set-at ;

GENERIC: lower-colon>object ( obj -- obj' )
GENERIC: double-quote>object ( obj -- obj' )
GENERIC: bracket-container>object ( obj -- obj' )
GENERIC: brace-container>object ( obj -- obj' )
GENERIC: paren-container>object ( obj -- obj' )

![[
    SYNTAX: LOWER-COLON:
    scan-new-class
    [ ]
    [ tuple { "object" } define-tuple-class ]
    [ '[ _ boa suffix! ] define-lower-colon-word ] tri ;
]]


ERROR: no-single-quote-word payload word ;
: handle-single-quote ( pair -- obj )
    first2 swap single-quote-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-single-quote-word ] if ;

: ch>object ( ch -- obj )
    {
        { [ dup length 1 = ] [ first ] }
        { [ "\\" ?head ] [ next-escape >string "" assert= ] }
        [ name>char-hook get ( name -- char ) call-effect ]
    } cond ;

\ ch>object "ch" single-quote-definitions get set-at



ERROR: no-lower-colon-word payload word ;
: handle-lower-colon ( pair -- obj )
    first2 swap lower-colon-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-lower-colon-word ] if ;

: no-op ( obj -- obj' ) ;
\ no-op "data-stack" lower-colon-definitions get set-at
