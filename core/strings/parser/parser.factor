! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators continuations kernel
kernel.private lexer math math.parser namespaces sbufs sequences
splitting strings ;
IN: strings.parser

ERROR: bad-escape char ;

: escape ( escape -- ch )
    H{
        { char: a  char: \a }
        { char: b  char: \b }
        { char: e  char: \e }
        { char: f  char: \f }
        { char: n  char: \n }
        { char: r  char: \r }
        { char: t  char: \t }
        { char: s  char: \s }
        { char: v  char: \v }
        { char: \s char: \s }
        { char: 0  char: \0 }
        { char: \! char: \! }
        { char: \\ char: \\ }
        { char: \" char: \" }
        { char: \: char: \: }
        { char: \[ char: \[ }
        { char: \{ char: \{ }
        { char: \( char: \( }
        { char: \; char: \; }
        { char: \] char: \] }
        { char: \} char: \} }
        { char: \) char: \) }
        { char: \' char: \' }
        { char: \# char: \# }
    } ?at [ bad-escape ] unless ;

INITIALIZED-SYMBOL: name>char-hook [
    [ "Unicode support not available" throw ]
]

: hex-escape ( str -- ch str' )
    2 cut-slice [ hex> ] dip ;

: unicode-escape ( str -- ch str' )
    "{" ?head-slice [
        char: \} over index cut-slice [
            dup hex> [
                nip
            ] [
                >string name>char-hook get call( name -- char )
            ] if*
        ] dip rest-slice
    ] [
        6 cut-slice [ hex> ] dip
    ] if ;

: next-escape ( str -- ch str' )
    unclip-slice {
        { char: u [ unicode-escape ] }
        { char: x [ hex-escape ] }
        [ escape swap ]
    } case ;

<PRIVATE

: (unescape-string) ( accum str i/f -- accum )
    { sbuf object object } declare
    [
        cut-slice [ append! ] dip
        rest-slice next-escape [ suffix! ] dip
        char: \\ over index (unescape-string)
    ] [
        append!
    ] if* ;

PRIVATE>

: unescape-string ( str -- str' )
    char: \\ over index [
        [ [ length <sbuf> ] keep ] dip (unescape-string)
    ] when* "" like ;

<PRIVATE

: lexer-subseq ( i lexer -- before )
    { fixnum lexer } declare
    [ [ column>> ] [ line-text>> ] bi swapd subseq ]
    [ column<< ] 2bi ;

: rest-of-line ( lexer -- seq )
    { lexer } declare
    [ line-text>> ] [ column>> ] bi tail-slice ;

: current-char ( lexer -- ch/f )
    { lexer } declare
    [ column>> ] [ line-text>> ] bi ?nth ;

: advance-char ( lexer -- )
    { lexer } declare
    [ 1 + ] change-column drop ;

: next-char ( lexer -- ch/f )
    { lexer } declare
    dup still-parsing-line? [
        [ current-char ] [ advance-char ] bi
    ] [
        drop f
    ] if ;

: next-line% ( accum lexer -- )
    { sbuf lexer } declare
    [ rest-of-line swap push-all ] [ next-line ] bi ;

: find-next-token ( lexer -- i elt )
    { lexer } declare
    [ column>> ] [ line-text>> ] bi
    [ "\"\\" member-eq? ] find-from ;

DEFER: (parse-string)

: parse-found-token ( accum lexer i elt -- )
    { sbuf lexer fixnum fixnum } declare
    [ over lexer-subseq pick push-all ] dip
    char: \\ eq? [
        dup dup [ next-char ] bi@
        [ [ pick push ] bi@ ]
        [ drop 2dup next-line% ] if*
        (parse-string)
    ] [
        dup advance-char
        dup current-char forbid-tab {
            { char: \s [ advance-char ] }
            { f [ drop ] }
            [ "[space]" swap 1string "'" dup surround unexpected ]
        } case drop
    ] if ;

: (parse-string) ( accum lexer -- )
    { sbuf lexer } declare
    dup still-parsing? [
        dup find-next-token [
            parse-found-token
        ] [
            drop 2dup next-line%
            char: \n pick push
            (parse-string)
        ] if*
    ] [
        "'\"'" "[eof]" unexpected
    ] if ;

PRIVATE>

: parse-string ( -- str )
    sbuf"" clone [
        lexer get (parse-string)
    ] keep unescape-string ;

: lookup-char ( char -- obj )
    {
        { [ dup length 1 = ] [ first ] }
        { [ "\\" ?head ] [ next-escape >string "" assert= ] }
        [ name>char-hook get ( name -- char ) call-effect ]
    } cond ;
