! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators kernel math math.order
multiline namespaces sequences splitting strings strings.parser ;
IN: syntax.modern

: matching-delimiter ( ch -- ch' )
    H{
        { ch'\( ch'\) }
        { ch'\[ ch'\] }
        { ch'\{ ch'\} }
        { ch'< ch'> }
        { ch'\: ch'\; }
    } ?at drop ;

: matching-delimiter-string ( string -- string' )
    [ matching-delimiter ] map ;

INITIALIZED-SYMBOL: lower-colon-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: upper-colon-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: section-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: named-section-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: single-quote-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: double-quote-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: bracket-container-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: brace-container-definitions [ H{ } clone ]
INITIALIZED-SYMBOL: paren-container-definitions [ H{ } clone ]

: set-lower-colon-word ( word name -- ) lower-colon-definitions get set-at ;
: set-upper-colon-word ( word name -- ) upper-colon-definitions get set-at ;
: set-section-word ( word name -- ) section-definitions get set-at ;
: set-named-section-word ( word name -- ) named-section-definitions get set-at ;
: set-single-quote-word ( word name -- ) single-quote-definitions get set-at ;
: set-double-quote-word ( word name -- ) double-quote-definitions get set-at ;
: set-bracket-container-word ( word name -- ) bracket-container-definitions get set-at ;
: set-brace-container-word ( word name -- ) brace-container-definitions get set-at ;
: set-paren-container-word ( word name -- ) paren-container-definitions get set-at ;

: set-container-word ( word def -- )
    {
        [ set-single-quote-word ]
        [ set-double-quote-word ]
        [ set-bracket-container-word ]
        [ set-brace-container-word ]
        [ set-paren-container-word ]
    } 2cleave ;

ERROR: no-lower-colon-word payload word ;
: handle-lower-colon ( pair -- obj )
    first2 swap lower-colon-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-lower-colon-word ] if ;

ERROR: no-single-quote-word payload word ;
: handle-single-quote ( pair -- obj )
    first2 swap single-quote-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-single-quote-word ] if ;

ERROR: no-section-word payload word ;
: handle-section ( pair -- obj )
    first2 swap section-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-section-word ] if ;

ERROR: no-named-section-word payload word ;
: handle-named-section ( pair -- obj )
    first2 swap named-section-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-named-section-word ] if ;

ERROR: no-double-quote-word payload word ;
: handle-double-quote ( pair -- obj )
    first2 swap double-quote-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-double-quote-word ] if ;

ERROR: no-bracket-container-word payload word ;
: handle-bracket-container ( pair -- obj )
    first2 swap bracket-container-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-bracket-container-word ] if ;

ERROR: no-brace-container-word payload word ;
: handle-brace-container ( pair -- obj )
    first2 swap brace-container-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-brace-container-word ] if ;

ERROR: no-paren-container-word payload word ;
: handle-paren-container ( pair -- obj )
    first2 swap paren-container-definitions get ?at
    [ execute( obj -- obj' ) ]
    [ no-paren-container-word ] if ;


: lower-char? ( str -- ? ) [ ch'a ch'z between? ] [ ch'- = ] bi or ;
: upper-char? ( str -- ? ) [ ch'A ch'Z between? ] [ ch'- = ] bi or ;


: strict-lower-colon? ( string -- ? )
    [ ch'\: = ] cut-tail
    [
        [ length 0 > ] [ [ lower-char? ] all? ] bi and
    ] [ length 0 > ] bi* and ;




: (strict-upper-colon?) ( string -- ? )
    ! All chars must...
    [
        [
            [ ch'A ch'Z between? ] [ "':-\\#" member? ] bi or
        ] all?
    ]
    ! At least one char must...
    [ [ [ ch'A ch'Z between? ] [ ch'\' = ] bi or ] any? ] bi and ;

: strict-upper-colon? ( string -- ? )
    [ [ ch'\: = ] all? ]
    [ (strict-upper-colon?) ] bi or ;


: strict-section-word? ( string -- ? )
    [ "<" head? ]
    [ rest [ upper-char? ] all? ] bi and ;

: strict-named-section-word? ( string -- ? )
    [ "<" head? ]
    [ ":" tail? ]
    [ rest but-last [ upper-char? ] all? ] tri and and ;

: (strict-single-quote?) ( string -- ? )
    "'" split1
    [ "'" head? not ]
    [
        [ length 0 > ]
        [
            ! ch'\'
            [ "\\'" tail? ] [ "'" tail? not ] bi or
        ] bi and
    ] bi* and ;

: strict-single-quote? ( string -- ? )
    dup (strict-single-quote?)
    [ "'[" sequence= not ] [ drop f ] if ;

: strict-double-quote? ( string -- ? ) ?last ch'\" = ;

: strict-container? ( string open-str -- ? )
    [ split1 ] [ split1 ] bi
    [ ]
    [ [ ch'= = ] all? ]
    [ "" = ] tri* and and ;

: strict-bracket-container? ( string -- ? ) "[" strict-container? ;
: strict-brace-container? ( string -- ? ) "{" strict-container? ;
: strict-paren-container? ( string -- ? ) "(" strict-container? ;

: container-tag ( string open-str -- string' ) split1 drop ;
: double-quote-tag ( string -- string' ) "\"" split1 drop ;
: bracket-container-tag ( string -- string' ) "[" container-tag ;
: brace-container-tag ( string -- string' ) "{" container-tag ;
: paren-container-tag ( string -- string' ) "(" container-tag ;

: parse-bracket-container ( string -- string' )
    "[" split1 "[" prepend matching-delimiter-string
    parse-multiline-string0 2array handle-bracket-container ;

: parse-brace-container ( string -- string' )
    "{" split1 "{" prepend matching-delimiter-string
    parse-multiline-string0 2array handle-brace-container ;

: parse-paren-container ( string -- string' )
    "(" split1 "(" prepend matching-delimiter-string
    parse-multiline-string0 2array handle-paren-container ;


\ lookup-char "ch" set-container-word
\ no-op "data-stack" set-lower-colon-word
! USE: urls \ >url "url" set-container-word


