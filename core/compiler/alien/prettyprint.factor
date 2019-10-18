! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint-internals
USING: alien kernel prettyprint math ;

M: alien pprint*
    dup expired? [
        drop "( alien expired )" text
    ] [
        \ ALIEN: pprint-word alien-address number>string text
    ] if ;

M: dll pprint* dll-path dup "DLL\" " pprint-string ;
