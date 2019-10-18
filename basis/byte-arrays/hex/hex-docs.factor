! Copyright (C) 2009 Maxim Savchenko, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: byte-arrays.hex
USING: byte-arrays help.markup help.syntax ;

HELP: HEX{
{ $syntax "HEX{ 0123 45 67 89abcdef }" }
{ $description "Constructs a " { $link byte-array } " from data specified in hexadecimal format. Whitespace between the curly braces is ignored. There must be an even number of hex digits or an error is thrown." } ;
