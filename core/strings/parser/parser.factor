! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators kernel kernel.private
lexer math math.parser namespaces sbufs sequences splitting
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

: hex-escape ( str -- ch str' )
    2 cut-slice [ hex> ] dip ;

: unicode-escape ( str -- ch str' )
    "{" ?head-slice [
        CHAR: } over index cut-slice
        [ >string name>char-hook get call( name -- char ) ] dip
        rest-slice
    ] [
        6 cut-slice [ hex> ] dip
    ] if ;

: next-escape ( str -- ch str' )
    unclip-slice {
        { CHAR: u [ unicode-escape ] }
        { CHAR: x [ hex-escape ] }
        [ escape swap ]
    } case ;

<PRIVATE

: (unescape-string) ( accum str i/f -- accum )
    { sbuf object object } declare
    [
        cut-slice [ over push-all ] dip
        rest-slice next-escape [ over push ] dip
        CHAR: \\ over index (unescape-string)
    ] [
        over push-all
    ] if* ;

PRIVATE>

: unescape-string ( str -- str' )
    CHAR: \\ over index [
        [ [ length <sbuf> ] keep ] dip (unescape-string)
    ] when* "" like ;

<PRIVATE

: (parse-string) ( accum str -- accum m )
    { sbuf slice } declare
    dup [ "\"\\" member? ] find [
        [ cut-slice [ over push-all ] dip rest-slice ] dip
        CHAR: " = [
            from>>
        ] [
            next-escape [ over push ] dip (parse-string)
        ] if
    ] [
        "Unterminated string" throw
    ] if* ;

PRIVATE>

: parse-string ( -- str )
    lexer get [
        [ SBUF" " clone ] 2dip swap tail-slice
        (parse-string) [ "" like ] dip
    ] change-lexer-column ;

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

ERROR: escaped-char-expected ;

: next-char ( lexer -- ch )
    { lexer } declare
    dup still-parsing-line? [
        [ current-char ] [ advance-char ] bi
    ] [
        escaped-char-expected
    ] if ;

: lexer-head? ( lexer string -- ? )
    { lexer string } declare
    [ rest-of-line ] dip head? ;

: advance-lexer ( lexer n -- )
    { lexer fixnum } declare
    [ + ] curry change-column drop ;

: find-next-token ( lexer ch -- i elt )
    { lexer fixnum } declare
    [ [ column>> ] [ line-text>> ] bi ] dip
    CHAR: \ 2array [ member? ] curry find-from ;

: next-line% ( accum lexer -- )
    { sbuf lexer } declare
    [ rest-of-line swap push-all ]
    [ next-line CHAR: \n swap push ] 2bi ;

: take-double-quotes ( lexer -- string )
    { lexer } declare
    dup current-char CHAR: " = [
        dup [ column>> ] [ line-text>> ] bi
        [ CHAR: " = not ] find-from drop [
            over column>> - CHAR: " <repetition>
        ] [
            dup rest-of-line
        ] if*
        [ length advance-lexer ] keep
    ] [ drop f ] if ;

: end-string-parse ( accum lexer delimiter -- )
    { sbuf lexer string } declare
    length 3 = [
        take-double-quotes 3 tail-slice swap push-all
    ] [
        advance-char drop
    ] if ;

DEFER: (parse-multiline-string)

: parse-found-token ( accum lexer string i token -- )
    { sbuf lexer string fixnum fixnum } declare
    [ [ 2over ] dip swap lexer-subseq swap push-all ] dip
    CHAR: \ = [
        2over next-char swap push
        2over next-char swap push
        (parse-multiline-string)
    ] [
        2dup lexer-head? [
            end-string-parse
        ] [
            2over next-char swap push
            (parse-multiline-string)
        ] if
    ] if ;

ERROR: trailing-characters string ;

: (parse-multiline-string) ( accum lexer string -- )
    { sbuf lexer fixnum } declare
    over still-parsing? [
        2dup first find-next-token [
            parse-found-token
        ] [
            drop 2over next-line%
            (parse-multiline-string)
        ] if*
    ] [
        throw-unexpected-eof
    ] if ;

PRIVATE>

: parse-multiline-string ( -- string )
    SBUF" " clone [
        lexer get
        dup rest-of-line "\"\"" head? [
            [ 2 + ] change-column
            "\"\"\""
        ] [
            "\""
        ] if (parse-multiline-string)
    ] keep unescape-string ;
