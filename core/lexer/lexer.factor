! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors namespaces math words strings
io vectors arrays math.parser combinators continuations ;
IN: lexer

TUPLE: lexer text line line-text line-length column ;

: next-line ( lexer -- )
    dup [ line>> ] [ text>> ] bi ?nth >>line-text
    dup line-text>> length >>line-length
    [ 1 + ] change-line
    0 >>column
    drop ;

: new-lexer ( text class -- lexer )
    new
        0 >>line
        swap >>text
    dup next-line ; inline

: <lexer> ( text -- lexer )
    lexer new-lexer ;

: skip ( i seq ? -- n )
    over length
    [ [ swap CHAR: \s eq? xor ] curry find-from drop ] dip or ;

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
    [ line>> ] [ text>> ] bi length <= ;

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

ERROR: unexpected want got ;

PREDICATE: unexpected-eof < unexpected
    got>> not ;

: unexpected-eof ( word -- * ) f unexpected ;

: expect ( token -- )
    scan
    [ 2dup = [ 2drop ] [ unexpected ] if ]
    [ unexpected-eof ]
    if* ;

: (parse-tokens) ( accum end -- accum )
    scan 2dup = [
        2drop
    ] [
        [ pick push (parse-tokens) ] [ unexpected-eof ] if*
    ] if ;

: parse-tokens ( end -- seq )
    100 <vector> swap (parse-tokens) >array ;

TUPLE: lexer-error line column line-text error ;

: <lexer-error> ( msg -- error )
    \ lexer-error new
        lexer get
        [ line>> >>line ]
        [ column>> >>column ]
        [ line-text>> >>line-text ]
        tri
        swap >>error ;

: lexer-dump ( error -- )
    [ line>> number>string ": " append ]
    [ line-text>> dup string? [ drop "" ] unless ]
    [ column>> 0 or ] tri
    pick length + CHAR: \s <string>
    [ write ] [ print ] [ write "^" print ] tri* ;

: with-lexer ( lexer quot -- newquot )
    [ lexer set ] dip [ <lexer-error> rethrow ] recover ; inline

SYMBOL: lexer-factory

[ <lexer> ] lexer-factory set-global
