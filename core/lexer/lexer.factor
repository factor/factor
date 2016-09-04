! Copyright (C) 2008, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators continuations io kernel
kernel.private math math.parser namespaces sequences
sequences.private source-files.errors strings vectors ;
IN: lexer

TUPLE: lexer
{ text array }
{ line fixnum }
{ line-text string }
{ line-length fixnum }
{ column fixnum }
{ parsing-words vector } ;

TUPLE: lexer-parsing-word word line line-text column ;

ERROR: not-a-lexer object ;

: check-lexer ( lexer -- lexer )
    dup lexer? [ not-a-lexer ] unless ; inline

: next-line ( lexer -- )
    check-lexer
    dup [ line>> ] [ text>> ] bi ?nth "" or
    [ >>line-text ] [ length >>line-length ] bi
    [ 1 + ] change-line
    0 >>column
    drop ;

: push-parsing-word ( word -- )
    lexer get check-lexer [
        [ line>> ] [ line-text>> ] [ column>> ] tri
        lexer-parsing-word boa
    ] [ parsing-words>> push ] bi ;

: pop-parsing-word ( -- )
    lexer get check-lexer parsing-words>> pop* ;

: new-lexer ( text class -- lexer )
    new
        0 >>line
        swap >>text
        V{ } clone >>parsing-words
    dup next-line ; inline

: <lexer> ( text -- lexer )
    lexer new-lexer ;

ERROR: unexpected want got ;

: forbid-tab ( c -- c )
    [ CHAR: \t eq? [ "[space]" "[tab]" unexpected ] when ] keep ; inline

: skip ( i seq ? -- n )
    over length [
        [ swap forbid-tab CHAR: \s eq? xor ] curry find-from drop
    ] dip or ; inline

: change-lexer-column ( ..a lexer quot: ( ..a col line -- ..b newcol ) -- ..b )
    [ check-lexer [ column>> ] [ line-text>> ] bi ] prepose
    keep column<< ; inline

GENERIC: skip-blank ( lexer -- )

<PRIVATE

: shebang? ( lexer -- lexer ? )
    dup line>> 1 = [
        dup column>> zero? [
            dup line-text>> "#!" head?
        ] [ f ] if
    ] [ f ] if ; inline

PRIVATE>

M: lexer skip-blank
    shebang? [
        [ nip length ] change-lexer-column
    ] [
        [ t skip ] change-lexer-column
    ] if ;

GENERIC: skip-word ( lexer -- )

M: lexer skip-word
    [
        2dup nth CHAR: \" eq? [ drop 1 + ] [ f skip ] if
    ] change-lexer-column ;

: still-parsing? ( lexer -- ? )
    check-lexer [ line>> ] [ text>> length ] bi <= ;

: still-parsing-line? ( lexer -- ? )
    check-lexer [ column>> ] [ line-length>> ] bi < ;

: (parse-raw) ( lexer -- str )
    check-lexer {
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

: simple-lexer-dump ( error -- )
    [ line>> number>string ": " append ]
    [ line-text>> ]
    [ column>> ] tri
    pick length + CHAR: \s <string>
    [ write ] [ print ] [ write "^" print ] tri* ;

: (parsing-word-lexer-dump) ( error parsing-word -- )
    [
        line>> number>string
        over line>> number>string length
        CHAR: \s pad-head
        ": " append write
    ] [ line-text>> print ] bi
    simple-lexer-dump ;

: parsing-word-lexer-dump ( error parsing-word -- )
    2dup [ line>> ] same?
    [ drop simple-lexer-dump ]
    [ (parsing-word-lexer-dump) ] if ;

: lexer-dump ( error -- )
    dup parsing-words>>
    [ simple-lexer-dump ]
    [ last parsing-word-lexer-dump ] if-empty ;

: with-lexer ( lexer quot -- newquot )
    [ [ <lexer-error> rethrow ] recover ] curry
    [ lexer ] dip with-variable ; inline
