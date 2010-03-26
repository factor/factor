! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors namespaces math words strings
io vectors arrays math.parser combinators continuations
source-files.errors ;
IN: lexer

TUPLE: lexer text line line-text line-length column parsing-words ;

TUPLE: lexer-parsing-word word line line-text column ;

: next-line ( lexer -- )
    dup [ line>> ] [ text>> ] bi ?nth >>line-text
    dup line-text>> length >>line-length
    [ 1 + ] change-line
    0 >>column
    drop ;

: push-parsing-word ( word -- )
    lexer-parsing-word new
        swap >>word
        lexer get [
            [ line>>      >>line      ]
            [ line-text>> >>line-text ]
            [ column>>    >>column    ] tri
        ] [ parsing-words>> push ] bi ;

: pop-parsing-word ( -- )
    lexer get parsing-words>> pop drop ;

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
    over length
    [ [ swap forbid-tab CHAR: \s eq? xor ] curry find-from drop ] dip or ;

: change-lexer-column ( lexer quot -- )
    [ [ column>> ] [ line-text>> ] bi ] prepose keep
    (>>column) ; inline

GENERIC: skip-blank ( lexer -- )

M: lexer skip-blank ( lexer -- )
    [ t skip ] change-lexer-column ;

GENERIC: skip-word ( lexer -- )

M: lexer skip-word ( lexer -- )
    [
        2dup nth CHAR: " eq? [ drop 1 + ] [ f skip ] if
    ] change-lexer-column ;

: still-parsing? ( lexer -- ? )
    [ line>> ] [ text>> length ] bi <= ;

: still-parsing-line? ( lexer -- ? )
    [ column>> ] [ line-length>> ] bi < ;

: (parse-token) ( lexer -- str )
    {
        [ column>> ]
        [ skip-word ]
        [ column>> ]
        [ line-text>> ]
    } cleave subseq ;

:  parse-token ( lexer -- str/f )
    dup still-parsing? [
        dup skip-blank
        dup still-parsing-line?
        [ (parse-token) ] [ dup next-line parse-token ] if
    ] [ drop f ] if ;

: scan ( -- str/f ) lexer get parse-token ;

PREDICATE: unexpected-eof < unexpected got>> not ;

: unexpected-eof ( word -- * ) f unexpected ;

: expect ( token -- )
    scan
    [ 2dup = [ 2drop ] [ unexpected ] if ]
    [ unexpected-eof ]
    if* ;

: each-token ( ... end quot: ( ... token -- ... ) -- ... )
    [ scan ] 2dip {
        { [ 2over = ] [ 3drop ] }
        { [ pick not ] [ drop unexpected-eof ] }
        [ [ nip call ] [ each-token ] 2bi ]
    } cond ; inline recursive

: map-tokens ( ... end quot: ( ... token -- ... elt ) -- ... seq )
    collector [ each-token ] dip { } like ; inline

: parse-tokens ( end -- seq )
    [ ] map-tokens ;

TUPLE: lexer-error line column line-text parsing-words error ;

M: lexer-error error-file error>> error-file ;

M: lexer-error error-line [ error>> error-line ] [ line>> ] bi or ;

: <lexer-error> ( msg -- error )
    \ lexer-error new
        lexer get [
            [ line>> >>line ]
            [ column>> >>column ] bi
        ] [ 
            [ line-text>> >>line-text ]
            [ parsing-words>> clone >>parsing-words ] bi
        ] bi
        swap >>error ;

: simple-lexer-dump ( error -- )
    [ line>> number>string ": " append ]
    [ line-text>> dup string? [ drop "" ] unless ]
    [ column>> 0 or ] tri
    pick length + CHAR: \s <string>
    [ write ] [ print ] [ write "^" print ] tri* ;

: (parsing-word-lexer-dump) ( error parsing-word -- )
    [
        line>> number>string
        over line>> number>string length
        CHAR: \s pad-head
        ": " append write
    ] [ line-text>> dup string? [ drop "" ] unless print ] bi
    simple-lexer-dump ;

: parsing-word-lexer-dump ( error parsing-word -- )
    2dup [ line>> ] bi@ =
    [ drop simple-lexer-dump ]
    [ (parsing-word-lexer-dump) ] if ;

: lexer-dump ( error -- )
    dup parsing-words>> [ simple-lexer-dump ] [ last parsing-word-lexer-dump ] if-empty ;

: with-lexer ( lexer quot -- newquot )
    [ lexer set ] dip [ <lexer-error> rethrow ] recover ; inline

SYMBOL: lexer-factory

[ <lexer> ] lexer-factory set-global
