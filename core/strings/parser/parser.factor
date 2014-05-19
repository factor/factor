! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators kernel lexer
math math.parser namespaces sbufs sequences splitting strings ;
IN: strings.parser

ERROR: bad-escape char ;

: escape ( escape -- ch )
    H{
        { CHAR: a  CHAR: \a }
        { CHAR: e  CHAR: \e }
        { CHAR: n  CHAR: \n }
        { CHAR: r  CHAR: \r }
        { CHAR: t  CHAR: \t }
        { CHAR: s  CHAR: \s }
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
    dup first {
        { CHAR: u [ rest-slice unicode-escape ] }
        { CHAR: x [ rest-slice hex-escape ] }
        [ drop unclip-slice escape swap ]
    } case ;

<PRIVATE

: (unescape-string) ( accum str i/f -- accum )
    [
        cut-slice [ over push-all ] dip
        rest-slice next-escape [ over push ] dip
        CHAR: \\ over index (unescape-string)
    ] [
        over push-all
    ] if* ; inline recursive

PRIVATE>

: unescape-string ( str -- str' )
    CHAR: \\ over index [
        [ [ length <sbuf> ] keep ] dip (unescape-string)
    ] when* "" like ;

<PRIVATE

: (parse-string) ( accum str -- accum m )
    dup [ "\"\\" member? ] find [
        [ cut-slice [ over push-all ] dip rest-slice ] dip
        CHAR: " = [
            from>>
        ] [
            next-escape [ over push ] dip (parse-string)
        ] if
    ] [
        "Unterminated string" throw
    ] if* ; inline recursive

PRIVATE>

: parse-string ( -- str )
    lexer get [
        [ SBUF" " clone ] 2dip swap tail-slice
        (parse-string) [ "" like ] dip
    ] change-lexer-column ;

<PRIVATE

: lexer-subseq ( i lexer -- before )
    [ [ column>> ] [ line-text>> ] bi swapd subseq ]
    [ column<< ] 2bi ;

: rest-of-line ( lexer -- seq )
    [ line-text>> ] [ column>> ] bi tail-slice ;

: current-char ( lexer -- ch/f )
    [ column>> ] [ line-text>> ] bi ?nth ;

: advance-char ( lexer -- )
    [ 1 + ] change-column drop ;

ERROR: escaped-char-expected ;

: next-char ( lexer -- ch )
    dup still-parsing-line? [
        [ current-char ] [ advance-char ] bi
    ] [
        escaped-char-expected
    ] if ;

: lexer-head? ( lexer string -- ? )
    [ rest-of-line ] dip head? ;

: advance-lexer ( lexer n -- )
    [ + ] curry change-column drop ; inline

: find-next-token ( lexer ch -- i elt )
    [ [ column>> ] [ line-text>> ] bi ] dip
    CHAR: \ 2array [ member? ] curry find-from ;

: next-line% ( accum lexer -- )
    [ rest-of-line swap push-all ]
    [ next-line CHAR: \n swap push ] 2bi ; inline

: take-double-quotes ( lexer -- string )
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
    length 3 = [
        take-double-quotes 3 tail-slice swap push-all
    ] [
        advance-char drop
    ] if ; inline

DEFER: (parse-multiline-string)

: parse-found-token ( accum lexer string i token -- )
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
    ] if ; inline recursive

ERROR: trailing-characters string ;

: (parse-multiline-string) ( accum lexer string -- )
    over still-parsing? [
        2dup first find-next-token [
            parse-found-token
        ] [
            drop 2over next-line%
            (parse-multiline-string)
        ] if*
    ] [
        throw-unexpected-eof
    ] if ; inline recursive

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
