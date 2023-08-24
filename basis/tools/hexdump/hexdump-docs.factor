! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences byte-arrays
strings ;
IN: tools.hexdump

HELP: hexdump.
{ $values { "byte-array" byte-array } }
{ $description "Converts a sequence to its hexadecimal and ASCII representation sixteen characters at a time and writes it to standard out." } ;

HELP: hexdump
{ $values { "byte-array" byte-array } { "str" string } }
{ $description "Converts a sequence to its hexadecimal and ASCII representation sixteen characters at a time. Lines are separated by a newline character." }
{ $see-also hexdump. } ;

ARTICLE: "tools.hexdump" "Hexdump"
"The " { $vocab-link "tools.hexdump" } " vocabulary provides a traditional hexdump view of a sequence." $nl
"Write hexdump to string:"
{ $subsections hexdump }
"Write the hexdump to the output stream:"
{ $subsections hexdump. } ;

ABOUT: "tools.hexdump"
