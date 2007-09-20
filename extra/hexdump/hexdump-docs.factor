USING: help.markup help.syntax hexdump kernel ;

HELP: hexdump.
{ $values { "seq" "a sequence" } }
{ $description "Converts a sequence to its hexadecimal and ASCII representation sixteen characters at a time and writes it to standard out." } ;

HELP: hexdump
{ $values { "seq" "a sequence" } { "str" "a string" } }
{ $description "Converts a sequence to its hexadecimal and ASCII representation sixteen characters at a time.  Lines are separated by a newline character." }
{ $see-also hexdump. } ;

