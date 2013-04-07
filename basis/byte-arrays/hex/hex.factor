! Copyright (C) 2009,2011 Maxim Savchenko, Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: ascii grouping kernel math.parser sequences
strings.parser lexer math ;
IN: byte-arrays.hex

ERROR: odd-length-hex-string string ;

SYNTAX: HEX{
    "}" parse-tokens concat
    [ blank? not ] filter
    dup length even? [ odd-length-hex-string ] unless
    2 <groups> [ hex> ] B{ } map-as
    suffix! ;
