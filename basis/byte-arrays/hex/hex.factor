! Copyright (C) 2009 Maxim Savchenko, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: grouping lexer ascii parser sequences kernel math.parser ;
IN: byte-arrays.hex

SYNTAX: HEX{
    "}" parse-tokens "" join
    [ blank? not ] filter
    2 group [ hex> ] B{ } map-as
    suffix! ;
