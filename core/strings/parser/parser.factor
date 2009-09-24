! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel lexer make math math.parser
namespaces parser sequences splitting strings arrays
math.order ;
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

: unicode-escape ( str -- ch str' )
    "{" ?head-slice [
        CHAR: } over index cut-slice
        [ >string name>char-hook get call( name -- char ) ] dip
        rest-slice
    ] [
        6 cut-slice [ hex> ] dip
    ] if ;

: next-escape ( str -- ch str' )
    "u" ?head-slice [
        unicode-escape
    ] [
        unclip-slice escape swap
    ] if ;

: (unescape-string) ( str -- )
    CHAR: \\ over index dup [
        cut-slice [ % ] dip rest-slice
        next-escape [ , ] dip
        (unescape-string)
    ] [
        drop %
    ] if ;

: unescape-string ( str -- str' )
    [ (unescape-string) ] "" make ;

: (parse-string) ( str -- m )
    dup [ "\"\\" member? ] find dup [
        [ cut-slice [ % ] dip rest-slice ] dip
        CHAR: " = [
            from>>
        ] [
            next-escape [ , ] dip (parse-string)
        ] if
    ] [
        "Unterminated string" throw
    ] if ;

: parse-string ( -- str )
    lexer get [
        [ swap tail-slice (parse-string) ] "" make swap
    ] change-lexer-column ;

<PRIVATE

: lexer-before ( i -- before )
    [
        [
            lexer get
            [ column>> ] [ line-text>> ] bi
        ] dip swap subseq
    ] [
        lexer get (>>column)
    ] bi ;

: find-next-token ( ch -- i elt )
    CHAR: \ 2array
    [ lexer get [ column>> ] [ line-text>> ] bi ] dip
    [ member? ] curry find-from ;

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

: next-line% ( lexer -- )
    [ rest-of-line % ]
    [ next-line "\n" % ] bi ;

: rest-begins? ( string -- ? )
    [
        lexer get [ line-text>> ] [ column>> ] bi tail-slice
    ] dip head? ;

: advance-lexer ( n -- )
    [ lexer get ] dip [ + ] curry change-column drop ; inline

: take-double-quotes ( -- string )
    lexer get dup current-char CHAR: " = [
        [ ] [ column>> ] [ line-text>> ] tri
        [ CHAR: " = not ] find-from drop [
            swap column>> - CHAR: " <repetition>
        ] [
            rest-of-line
        ] if*
    ] [
        drop f
    ] if dup length advance-lexer ;

: end-string-parse ( delimiter -- )
    length 3 = [
        take-double-quotes 3 tail %
    ] [
        lexer get advance-char
    ] if ;

DEFER: (parse-long-string)

: parse-found-token ( i string token -- )
    [ lexer-before % ] dip
    CHAR: \ = [
        lexer get [ next-char , ] [ next-char , ] bi (parse-long-string)
    ] [
        dup rest-begins? [
            end-string-parse
        ] [
            lexer get next-char , (parse-long-string)
        ] if
    ] if ;

ERROR: trailing-characters string ;

: (parse-long-string) ( string -- )
    lexer get still-parsing? [
        dup first find-next-token [
            parse-found-token
        ] [
            drop lexer get next-line%
            (parse-long-string)
        ] if*
    ] [
        unexpected-eof
    ] if ;

PRIVATE>

: parse-long-string ( string -- string' )
    [ (parse-long-string) ] "" make ;

: parse-multiline-string ( -- string )
    lexer get rest-of-line "\"\"" head? [
        lexer get [ 2 + ] change-column drop
        "\"\"\""
    ] [
        "\""
    ] if parse-long-string unescape-string ;
