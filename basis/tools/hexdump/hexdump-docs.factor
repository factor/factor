! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences strings ;
IN: tools.hexdump

HELP: hexdump.
{ $values { "seq" sequence } }
{ $description "Converts a sequence to its hexadecimal and ASCII representation sixteen characters at a time and writes it to standard out." } ;

HELP: hexdump
{ $values { "seq" sequence } { "str" string } }
{ $description "Converts a sequence to its hexadecimal and ASCII representation sixteen characters at a time.  Lines are separated by a newline character." }
{ $see-also hexdump. } ;

ARTICLE: "hexdump" "Hexdump"
"The " { $vocab-link "hexdump" } " vocabulary provides a traditional hexdump view of a sequence." $nl
"Write hexdump to string:"
{ $subsection hexdump }
"Write the hexdump to the output stream:"
{ $subsection hexdump. } ;

ABOUT: "hexdump"
