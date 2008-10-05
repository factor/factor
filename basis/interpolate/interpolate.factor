! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel macros make multiline namespaces parser
peg.ebnf present sequences strings ;
IN: interpolate

MACRO: interpolate ( string -- )
[EBNF
var = "${" [^}]+ "}" => [[ second >string [ get present write ] curry ]]
text = [^$]+ => [[ >string [ write ] curry ]]
interpolate = (var|text)* => [[ [ ] join ]]
EBNF] ;

EBNF: interpolate-locals
var = "${" [^}]+ "}" => [[ [ second >string search , [ present write ] % ] [ ] make ]]
text = [^$]+ => [[ [ >string , [ write ] % ] [ ] make ]]
interpolate = (var|text)* => [[ [ ] join ]]
;EBNF

: I[ "]I" parse-multiline-string
    interpolate-locals parsed \ call parsed ; parsing
