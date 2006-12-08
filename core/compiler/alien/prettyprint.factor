! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint-internals
USING: alien kernel prettyprint math ;

M: alien pprint*
    dup expired? [
        drop "( alien expired )"
    ] [
        \ ALIEN: pprint-word alien-address number>string
    ] if text ;

M: dll pprint*
    dll-path alien>char-string "DLL\" " pprint-string ;
