! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions errors generic assocs kernel math
namespaces prettyprint sequences strings vectors words
quotations inspector styles io ;
IN: parser

SYMBOL: use
SYMBOL: in

TUPLE: check-vocab name ;

: check-vocab ( name -- vocab )
    dup vocab [ ] [
        <check-vocab>
        { { "Continue" f } } throw-restarts
    ] ?if ;

: word/vocab. ( word -- )
    dup word-vocabulary dup <vocab-link> write-object bl
    pprint ;

: shadow-warning ( new old -- )
    2dup eq? "quiet" get or [
        2drop
    ] [
        "Note: (" write word/vocab.
        ") is shadowed by (" write word/vocab. ")" print
    ] if ;

SYMBOL: check-shadowing

t check-shadowing set-global

: shadow-warnings ( vocab vocabs -- )
    check-shadowing get [
        swap [
            swap rot assoc-stack dup
            [ shadow-warning ] [ 2drop ] if
        ] assoc-each-with
    ] [
        2drop
    ] if ;

: use+ ( vocab -- )
    check-vocab [ use get 2dup shadow-warnings push ] when* ;

: add-use ( seq -- ) [ use+ ] each ;

: set-use ( seq -- )
    [ check-vocab ] map [ ] subset >vector use set ;

: check-vocab-string ( name -- name )
    dup string?
    [ "Vocabulary name must be a string" throw ] unless ;

: set-in ( name -- )
    check-vocab-string
    dup create-vocab drop
    dup in set use+ ;

: create-in ( string -- word )
    in get create dup save-location ;

TUPLE: unexpected want got ;

: unexpected ( want got -- * ) <unexpected> throw ;

PREDICATE: unexpected unexpected-eof
    unexpected-got not ;

: unexpected-eof ( word -- * ) f unexpected ;

: (parse-tokens) ( accum end -- accum )
    scan 2dup = [
        2drop
    ] [
        [ pick push (parse-tokens) ] [ unexpected-eof ] if*
    ] if ;

: parse-tokens ( end -- seq )
    100 <vector> swap (parse-tokens) >array ;

: CREATE ( -- word ) scan create-in ;

: word-restarts ( string -- restarts )
    words-named natural-sort
    [ [ "Use the word " swap summary append ] keep ] { } map>assoc
    { "Defer this word in the 'scratchpad' vocabulary" f } add ;

TUPLE: no-word name ;

: no-word ( name -- word/f )
    dup <no-word> swap word-restarts throw-restarts ;

: search ( str -- word )
    dup use get assoc-stack [ ] [
        dup no-word [
            dup word-vocabulary use+
        ] [
            "scratchpad" create
        ] ?if
    ] ?if ;

: scan-word ( -- word/number/f )
    scan dup [ dup string>number [ ] [ search ] ?if ] when ;

: parse-step ( accum end -- accum ? )
    scan-word {
        { [ 2dup eq? ] [ 2drop f ] }
        { [ dup not ] [ drop unexpected-eof t ] }
        { [ dup delimiter? ] [ unexpected t ] }
        { [ dup parsing? ] [ nip execute t ] }
        { [ t ] [ pick push drop t ] }
    } cond ;

: (parse-until) ( accum end -- accum )
    dup >r parse-step [ r> (parse-until) ] [ r> drop ] if ;

: parse-until ( end -- vec )
    100 <vector> swap (parse-until) ;

: parsed ( accum obj -- accum ) over push ;

: with-parser ( lexer quot -- newquot )
    swap lexer set
    [ call >quotation ] [ <parse-error> rethrow ] recover ;

: (parse-lines) ( lexer -- quot )
    [ f parse-until ] with-parser ;

SYMBOL: lexer-factory

[ <lexer> ] lexer-factory set-global

: parse-lines ( lines -- quot )
    lexer-factory get call (parse-lines) ;

! Parsing word utilities
: string>effect ( seq -- effect )
    { "--" } split1 dup [
        <effect>
    ] [
        "Stack effect declaration must contain --" throw
    ] if ;

: parse-effect ( -- effect )
    ")" parse-tokens string>effect ;

TUPLE: bad-number ;
: bad-number ( -- * ) <bad-number> throw ;

: parse-base ( parsed base -- parsed )
    scan swap base> [ bad-number ] unless* parsed ;

: parse-literal ( accum end quot -- accum )
    >r parse-until r> call parsed ; inline

: parse-definition ( -- quot )
    \ ; parse-until >quotation ;

: in-target ( accum quot -- accum )
    [ parsed \ call parsed ] [ call ] if-bootstrapping ;
    inline

global [
    {
        "scratchpad" "syntax" "arrays" "assocs" "compiler"
        "definitions" "errors" "generic" "help" "inference"
        "inspector" "io" "kernel" "listener" "math" "memory"
        "modules" "namespaces" "parser" "prettyprint"
        "sequences" "shells" "strings" "tools" "words"
    } set-use
    "scratchpad" set-in
] bind
