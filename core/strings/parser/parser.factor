! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel summary assocs namespaces splitting sequences
strings math.parser lexer ;
IN: strings.parser

ERROR: bad-escape ;

M: bad-escape summary drop "Bad escape code" ;

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

name>char-hook global [
    [ "Unicode support not available" throw ] or
] change-at

: unicode-escape ( str -- ch str' )
    "{" ?head-slice [
        CHAR: } over index cut-slice
        >r >string name>char-hook get call r>
        rest-slice
    ] [
        6 cut-slice >r hex> r>
    ] if ;

: next-escape ( str -- ch str' )
    "u" ?head-slice [
        unicode-escape
    ] [
        unclip-slice escape swap
    ] if ;

: (parse-string) ( str -- m )
    dup [ "\"\\" member? ] find dup [
        >r cut-slice >r % r> rest-slice r>
        dup CHAR: " = [
            drop slice-from
        ] [
            drop next-escape >r , r> (parse-string)
        ] if
    ] [
        "Unterminated string" throw
    ] if ;

: parse-string ( -- str )
    lexer get [
        [ swap tail-slice (parse-string) ] "" make swap
    ] change-lexer-column ;
