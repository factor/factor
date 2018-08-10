! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators continuations kernel
kernel.private lexer math math.parser namespaces sbufs sequences
splitting strings ;
IN: strings.parser

ERROR: bad-escape char ;

: escape ( escape -- ch )
    H{
        { ch'a  ch'\a }
        { ch'b  ch'\b }
        { ch'e  ch'\e }
        { ch'f  ch'\f }
        { ch'n  ch'\n }
        { ch'r  ch'\r }
        { ch't  ch'\t }
        { ch's  ch'\s }
        { ch'v  ch'\v }
        { ch'\s ch'\s }
        { ch'0  ch'\0 }
        { ch'\! ch'\! }
        { ch'\\ ch'\\ }
        { ch'\" ch'\" }
        { ch'\: ch'\: }
        { ch'\[ ch'\[ }
        { ch'\{ ch'\{ }
        { ch'\( ch'\( }
        { ch'\; ch'\; }
        { ch'\] ch'\] }
        { ch'\} ch'\} }
        { ch'\) ch'\) }
        { ch'\' ch'\' }
    } ?at [ bad-escape ] unless ;

INITIALIZED-SYMBOL: name>char-hook [
    [ "Unicode support not available" throw ]
]

: hex-escape ( str -- ch str' )
    2 cut-slice [ hex> ] dip ;

: unicode-escape ( str -- ch str' )
    "{" ?head-slice [
        ch'\} over index cut-slice [
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
        { ch'u [ unicode-escape ] }
        { ch'x [ hex-escape ] }
        [ escape swap ]
    } case ;

<PRIVATE

: (unescape-string) ( accum str i/f -- accum )
    { sbuf object object } declare
    [
        cut-slice [ append! ] dip
        rest-slice next-escape [ suffix! ] dip
        ch'\\ over index (unescape-string)
    ] [
        append!
    ] if* ;

PRIVATE>

: unescape-string ( str -- str' )
    ch'\\ over index [
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
    [ "\"\\" member? ] find-from ;

DEFER: (parse-string)

: parse-found-token ( accum lexer i elt -- )
    { sbuf lexer fixnum fixnum } declare
    [ over lexer-subseq pick push-all ] dip
    ch'\\ = [
        dup dup [ next-char ] bi@
        [ [ pick push ] bi@ ]
        [ drop 2dup next-line% ] if*
        (parse-string)
    ] [
        advance-char drop
    ] if ;

: (parse-string) ( accum lexer -- )
    { sbuf lexer } declare
    dup still-parsing? [
        dup find-next-token [
            parse-found-token
        ] [
            drop 2dup next-line%
            ch'\n pick push
            (parse-string)
        ] if*
    ] [
        "Unterminated string" throw
    ] if ;

: rewind-lexer-on-error ( quot -- )
    lexer get [ line>> ] [ line-text>> ] [ column>> ] tri
    [
        lexer get [ column<< ] [ line-text<< ] [ line<< ] tri
        rethrow
    ] 3curry recover ; inline

PRIVATE>

: parse-string ( -- str )
    [
        sbuf"" clone [
            lexer get (parse-string)
        ] keep unescape-string
    ] rewind-lexer-on-error ;

: lookup-char ( char -- obj )
    {
        { [ dup length 1 = ] [ first ] }
        { [ "\\" ?head ] [ next-escape >string "" assert= ] }
        [ name>char-hook get ( name -- char ) call-effect ]
    } cond ;