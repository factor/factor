! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators kernel kernel.private lexer
math math.order math.parser namespaces sbufs sequences splitting
strings ;
IN: strings.parser

ERROR: bad-escape char ;

: escape ( escape -- ch )
    H{
        { CHAR: a  CHAR: \a }
        { CHAR: b  CHAR: \b }
        { CHAR: e  CHAR: \e }
        { CHAR: f  CHAR: \f }
        { CHAR: n  CHAR: \n }
        { CHAR: r  CHAR: \r }
        { CHAR: t  CHAR: \t }
        { CHAR: s  CHAR: \s }
        { CHAR: v  CHAR: \v }
        { CHAR: \s CHAR: \s }
        { CHAR: 0  CHAR: \0 }
        { CHAR: \\ CHAR: \\ }
        { CHAR: \" CHAR: \" }
    } ?at [ bad-escape ] unless ;

SYMBOL: name>char-hook

name>char-hook [
    [ "Unicode support not available" throw ]
] initialize

<PRIVATE

: hex-escape ( str -- ch str' )
    2 cut-slice [ hex> ] dip ;

: oct-escape ( str -- ch/f str' )
    dup 3 index-or-length head-slice [
        [ CHAR: 0 CHAR: 7 between? not ] find drop
    ] keep '[ _ length ] unless* [ f ] when-zero
    [ cut-slice [ oct> ] dip ] [ f swap ] if* ;

: unicode-escape ( str -- ch str' )
    "{" ?head-slice [
        CHAR: } over index cut-slice [
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
    oct-escape over [
        nip unclip-slice {
            { CHAR: u [ unicode-escape ] }
            { CHAR: x [ hex-escape ] }
            { CHAR: \n [ f swap ] }
            [ escape swap ]
        } case
    ] unless ;

: (unescape-string) ( accum str i/f -- accum )
    { sbuf object object } declare
    [
        cut-slice [ append! ] dip
        rest-slice next-escape [ [ suffix! ] when* ] dip
        CHAR: \\ over index (unescape-string)
    ] [
        append!
    ] if* ;

PRIVATE>

: unescape-string ( str -- str' )
    CHAR: \\ over index [
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

: check-space ( lexer -- )
    dup current-char forbid-tab {
        { CHAR: \s [ advance-char ] }
        { f [ drop ] }
        [ "[space]" swap 1string "'" 1surround unexpected ]
    } case ;

DEFER: (parse-string)

: parse-found-token ( accum lexer i elt -- )
    { sbuf lexer fixnum fixnum } declare
    [ over lexer-subseq pick push-all ] dip
    CHAR: \ eq? [
        dup dup [ next-char ] bi@
        [ [ pick push ] bi@ ]
        [ drop 2dup next-line% ] if*
        (parse-string)
    ] [ dup advance-char check-space drop ] if ;

: (parse-string) ( accum lexer -- )
    { sbuf lexer } declare
    dup still-parsing? [
        dup find-next-token [
            parse-found-token
        ] [
            drop 2dup next-line%
            CHAR: \n pick push
            (parse-string)
        ] if*
    ] [
        "'\"'" "[eof]" unexpected
    ] if ;

PRIVATE>

: parse-string ( -- str )
    SBUF" " clone [
        lexer get (parse-string)
    ] keep unescape-string ;
