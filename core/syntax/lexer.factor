! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays words math strings namespaces
errors assocs generic ;
IN: parser

SYMBOL: file

TUPLE: lexer text line column ;

C: lexer ( text -- lexer )
    [ set-lexer-text ] keep
    1 over set-lexer-line
    0 over set-lexer-column ;

: line-text ( lexer -- str )
    dup lexer-line 1- swap lexer-text ?nth ;

: location ( -- loc )
    file get lexer get lexer-line 2dup and
    [ 2array ] [ 2drop f ] if ;

: save-location ( word -- )
    dup set-word location "loc" set-word-prop ;

: next-line ( lexer -- )
    0 over set-lexer-column
    dup lexer-line 1+ swap set-lexer-line ;

: skip ( i seq quot -- n )
    over >r find* drop
    [ r> drop ] [ r> length ] if* ; inline

: change-column ( lexer quot -- )
    #! quot: ( n str -- n )
    swap
    [ dup lexer-column swap line-text rot call ] keep
    set-lexer-column ; inline

GENERIC: skip-blank ( lexer -- )

M: lexer skip-blank ( lexer -- )
    [ [ blank? not ] skip ] change-column ;

GENERIC: skip-word ( lexer -- )

M: lexer skip-word ( lexer -- )
    [
        2dup nth CHAR: " =
        [ drop 1+ ] [ [ blank? ] skip ] if
    ] change-column ;

: still-parsing? ( lexer -- ? )
    dup lexer-line swap lexer-text length <= ;

: still-parsing-line? ( lexer -- ? )
    dup lexer-column swap line-text length < ;

: (parse-token) ( lexer -- str )
    [ lexer-column ] keep
    [ skip-word ] keep
    [ lexer-column ] keep
    line-text subseq ;

:  parse-token ( lexer -- str/f )
    dup still-parsing? [
        dup skip-blank
        dup still-parsing-line?
        [ (parse-token) ] [ dup next-line parse-token ] if
    ] [ drop f ] if ;

: scan ( -- str/f ) lexer get parse-token ;

TUPLE: bad-escape ;

: bad-escape ( -- * ) <bad-escape> throw ;

: escape ( escape -- ch )
    H{
        { CHAR: e  CHAR: \e }
        { CHAR: n  CHAR: \n }
        { CHAR: r  CHAR: \r }
        { CHAR: t  CHAR: \t }
        { CHAR: s  CHAR: \s }
        { CHAR: \s CHAR: \s }
        { CHAR: 0  CHAR: \0 }
        { CHAR: \\ CHAR: \\ }
        { CHAR: \" CHAR: \" }
    } at [ bad-escape ] unless* ;

: next-escape ( n str -- n ch )
    2dup nth CHAR: u =
    [ >r 1+ dup 4 + tuck r> subseq hex> ]
    [ over 1+ -rot nth escape ] if ;

: next-char ( n str -- n ch )
    2dup nth CHAR: \\ =
    [ >r 1+ r> next-escape ] [ over 1+ -rot nth ] if ;

: (parse-string) ( n str -- n )
    2dup nth CHAR: " =
    [ drop 1+ ] [ [ next-char , ] keep (parse-string) ] if ;

: parse-string ( -- str )
    lexer get [
        [ (parse-string) ] "" make swap
    ] change-column ;

TUPLE: parse-error lexer file ;

C: parse-error ( msg -- error )
    lexer get over set-parse-error-lexer
    file get over set-parse-error-file
    [ set-delegate ] keep ;

: parse-error-line parse-error-lexer lexer-line ;

: parse-error-col parse-error-lexer lexer-column ;

: parse-error-text parse-error-lexer line-text ;
