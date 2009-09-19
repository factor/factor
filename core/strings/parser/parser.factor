! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel lexer make math math.parser
namespaces parser sequences splitting strings arrays ;
IN: strings.parser

ERROR: bad-escape ;

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
    } at [ bad-escape ] unless* ;

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

: lexer-advance ( i -- before )
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

: rest-of-line ( -- seq )
    lexer get [ line-text>> ] [ column>> ] bi tail-slice ;

: parse-escape ( i -- )
    lexer-advance % CHAR: \ ,
    lexer get
    [ [ 2 + ] change-column drop ]
    [ [ column>> 1 - ] [ line-text>> ] bi nth , ] bi ;

: next-string-line ( obj -- )
    drop rest-of-line %
    lexer get next-line "\n" % ;

: rest-begins? ( string -- ? )
    [
        lexer get [ line-text>> ] [ column>> ] bi tail-slice
    ] dip head? ;

DEFER: (parse-long-string)

: parse-rest-of-line ( string i token -- )
    CHAR: \ = [
        parse-escape (parse-long-string)
    ] [
        lexer-advance %
        dup rest-begins? [
            [ lexer get ] dip length [ + ] curry change-column drop
        ] [
            rest-of-line %
            lexer get next-line "\n" % (parse-long-string)
        ] if
    ] if ;

: parse-til-separator ( string -- )
    dup first find-next-token [
        parse-rest-of-line
    ] [
        next-string-line (parse-long-string)
    ] if* ;

: (parse-long-string) ( string -- )
    lexer get still-parsing? [
        parse-til-separator
    ] [
        unexpected-eof
    ] if ;

PRIVATE>

: parse-long-string ( string -- string' )
    [ (parse-long-string) ] "" make unescape-string ;

: parse-multiline-string ( -- string )
    rest-of-line "\"\"" head? [
        lexer get [ 2 + ] change-column drop
        "\"\"\"" parse-long-string
    ] [
        "\"" parse-long-string
    ] if ;
