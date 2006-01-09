! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: errors generic hashtables kernel lists math namespaces
sequences strings vectors words ;

SYMBOL: use
SYMBOL: in

: check-vocab ( name -- vocab )
    dup vocab
    [ ] [ " is not a vocabulary name" append throw ] ?if ;

: use+ ( string -- ) check-vocab use get push ;

: add-use ( seq -- ) [ use+ ] each ;

: set-use ( seq -- ) [ check-vocab ] map >vector use set ;

: set-in ( name -- ) dup ensure-vocab dup in set use+ ;

: parsing? ( word -- ? )
    dup word? [ "parsing" word-prop ] [ drop f ] if ;

SYMBOL: file
SYMBOL: line-number

SYMBOL: line-text
SYMBOL: column

TUPLE: parse-error file line col text ;

C: parse-error ( error -- error )
    file get over set-parse-error-file
    line-number get over set-parse-error-line
    column get over set-parse-error-col
    line-text get over set-parse-error-text
    [ set-delegate ] keep ;

: skip ( i seq quot -- n | quot: elt -- ? )
    over >r find* drop dup -1 =
    [ drop r> length ] [ r> drop ] if ; inline

: skip-blank ( -- )
    column [ line-text get [ blank? not ] skip ] change ;

: skip-word ( n line -- n )
    2dup nth CHAR: " = [ drop 1+ ] [ [ blank? ] skip ] if ;

: (scan) ( n line -- start end )
    dupd 2dup length < [ skip-word ] [ drop ] if ;

: scan ( -- token )
    skip-blank
    column [ line-text get (scan) dup ] change
    2dup = [ 2drop f ] [ line-text get subseq ] if ;

: save-location ( word -- )
    dup set-word
    dup line-number get "line" set-word-prop
    file get "file" set-word-prop ;

: create-in in get create dup save-location ;

: CREATE ( -- word ) scan create-in ;

SYMBOL: string-mode

: scan-word ( -- obj )
    scan dup [
        dup ";" = not string-mode get and [
            dup use get hash-stack [ ] [ string>number ] ?if
        ] unless
    ] when ;

: parse-loop ( -- )
    scan-word [
        dup parsing? [ execute ] [ swons ] if  parse-loop
    ] when* ;

: (parse) ( str -- ) line-text set 0 column set parse-loop ;

! Parsing word utilities
: ch-search ( ch -- index ) column get line-text get index* ;

: until ( index -- ) 1+ column set ;

: until-eol ( -- ) line-text get length until ;

: escape ( ch -- esc )
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
    } hash [ "Bad escape" throw ] unless* ;

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
    column
    [ [ line-text get (parse-string) ] "" make swap ] change ;

global [
    {
        "scratchpad" "syntax" "arrays" "compiler" "errors"
        "generic" "hashtables" "help" "inference" "inspector"
        "io" "jedit" "kernel" "listener" "lists" "math" "memory"
        "namespaces" "parser" "prettyprint" "queues" "sequences"
        "shells" "strings" "styles" "test" "threads" "vectors"
        "walker" "words"
    } set-use
    "scratchpad" set-in
] bind
