! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs namespaces make splitting sequences
strings math.parser lexer accessors ;
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
        [ >string name>char-hook get call ] dip
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

: (parse-string) ( str -- m )
    dup [ "\"\\" member? ] find dup [
        [ cut-slice [ % ] dip rest-slice ] dip
        dup CHAR: " = [
            drop from>>
        ] [
            drop next-escape [ , ] dip (parse-string)
        ] if
    ] [
        "Unterminated string" throw
    ] if ;

: parse-string ( -- str )
    lexer get [
        [ swap tail-slice (parse-string) ] "" make swap
    ] change-lexer-column ;

: (unescape-string) ( str -- str' )
    dup [ CHAR: \\ = ] find [
        cut-slice [ % ] dip rest-slice
        next-escape [ , ] dip
        (unescape-string)
    ] [
        drop %
    ] if ;

: unescape-string ( str -- str' )
    [ (unescape-string) ] "" make ;
