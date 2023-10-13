! Copyright (C) 2008, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes combinators continuations io
kernel math math.parser namespaces sequences source-files.errors
splitting strings vectors ;
IN: lexer

TUPLE: lexer
    { text array }
    { line fixnum }
    { line-text string }
    { line-length fixnum }
    { column fixnum }
    { parsing-words vector } ;

TUPLE: lexer-parsing-word word line line-text column ;

: next-line ( lexer -- )
    lexer check-instance
    dup [ line>> ] [ text>> ] bi ?nth "" or
    [ >>line-text ] [ length >>line-length ] bi
    [ 1 + ] change-line
    0 >>column
    drop ;

: push-parsing-word ( word -- )
    lexer get lexer check-instance [
        [ line>> ] [ line-text>> ] [ column>> ] tri
        lexer-parsing-word boa
    ] [ parsing-words>> push ] bi ;

: pop-parsing-word ( -- )
    lexer get lexer check-instance parsing-words>> pop* ;

: new-lexer ( text class -- lexer )
    [ dup string? [ split-lines ] when ] dip new
        0 >>line
        swap >>text
        V{ } clone >>parsing-words
    dup next-line ; inline

: <lexer> ( text -- lexer )
    lexer new-lexer ;

ERROR: unexpected want got ;

: change-lexer-column ( ..a lexer quot: ( ..a col line -- ..b newcol ) -- ..b )
    [ lexer check-instance [ column>> ] [ line-text>> ] bi ] prepose
    keep column<< ; inline

: forbid-tab ( c -- c )
    [ CHAR: \t eq? [ "[space]" "[tab]" unexpected ] when ] keep ; inline

<PRIVATE

: shebang? ( lexer -- lexer ? )
    dup line>> 1 = [
        dup column>> zero? [
            dup line-text>> "#!" head?
        ] [ f ] if
    ] [ f ] if ; inline

: (skip-blank) ( col line -- newcol )
    [ [ forbid-tab CHAR: \s eq? not ] find-from drop ]
    [ length or ] bi ;

: (skip-word) ( col line -- newcol )
    [ [ forbid-tab " \"" member-eq? ] find-from CHAR: \" eq? [ 1 + ] when ]
    [ length or ] bi ;

PRIVATE>

GENERIC: skip-blank ( lexer -- )

M: lexer skip-blank
    shebang? [
        [ nip length ] change-lexer-column
    ] [
        [ (skip-blank) ] change-lexer-column
    ] if ;

GENERIC: skip-word ( lexer -- )

M: lexer skip-word
    [ (skip-word) ] change-lexer-column ;

: still-parsing? ( lexer -- ? )
    lexer check-instance [ line>> ] [ text>> length ] bi <= ;

: still-parsing-line? ( lexer -- ? )
    lexer check-instance [ column>> ] [ line-length>> ] bi < ;

: (parse-raw) ( lexer -- str )
    lexer check-instance {
        [ column>> ]
        [ skip-word ]
        [ column>> ]
        [ line-text>> ]
    } cleave subseq ;

: parse-raw ( lexer -- str/f )
    dup still-parsing? [
        dup skip-blank
        dup still-parsing-line?
        [ (parse-raw) ] [ dup next-line parse-raw ] if
    ] [ drop f ] if ;

DEFER: parse-token

: skip-comments ( lexer str -- str' )
    dup "!" = [
        drop [ next-line ] keep parse-token
    ] [
        nip
    ] if ;

: parse-token ( lexer -- str/f )
    dup parse-raw [ skip-comments ] [ drop f ] if* ;

: ?scan-token ( -- str/f ) lexer get parse-token ;

PREDICATE: unexpected-eof < unexpected got>> not ;

: throw-unexpected-eof ( word -- * ) f unexpected ;

: scan-token ( -- str )
    ?scan-token [ "token" throw-unexpected-eof ] unless* ;

: expect ( token -- )
    scan-token 2dup = [ 2drop ] [ unexpected ] if ;

: each-token ( ... end quot: ( ... token -- ... ) -- ... )
    [ scan-token ] 2dip 2over =
    [ 3drop ] [ [ nip call ] [ each-token ] 2bi ] if ; inline recursive

: map-tokens ( ... end quot: ( ... token -- ... elt ) -- ... seq )
    collector [ each-token ] dip { } like ; inline

: parse-tokens ( end -- seq )
    [ ] map-tokens ;

TUPLE: lexer-error line column line-text parsing-words error ;

M: lexer-error error-file error>> error-file ;

M: lexer-error error-line [ error>> error-line ] [ line>> ] bi or ;

: <lexer-error> ( msg -- error )
    [
        lexer get {
            [ line>> ]
            [ column>> ]
            [ line-text>> ]
            [ parsing-words>> clone ]
        } cleave
    ] dip lexer-error boa ;

<PRIVATE

: simple-lexer-dump ( error -- )
    [ line>> number>string ": " append ]
    [ line-text>> ]
    [ column>> ] tri
    pick length + CHAR: \s <string>
    [ write ] [ print ] [ write "^" print ] tri* ;

: parsing-word-lexer-dump ( error parsing-word -- error )
    2dup [ line>> ] same? [ drop ] [
        [
            line>> number>string
            over line>> number>string length
            CHAR: \s pad-head
            ": " append write
        ] [ line-text>> print ] bi
    ] if ;

PRIVATE>

: lexer-dump ( error -- )
    dup parsing-words>> ?last [
        parsing-word-lexer-dump
    ] when* simple-lexer-dump ;

: with-lexer ( lexer quot -- newquot )
    [ [ <lexer-error> rethrow ] recover ] curry
    [ lexer ] dip with-variable ; inline
