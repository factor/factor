USING: help.markup help.syntax kernel math sequences ;
IN: math.bitfields.lib

HELP: bits 
{ $values { "m" integer } { "n" integer } { "m'" integer } }
{ $description "Keep only n bits from the integer m." }
{ $example "USING: math.bitfields.lib prettyprint ;" "HEX: 123abcdef 16 bits .h" "cdef" } ;

HELP: bitroll
{ $values { "x" "an integer (input)" } { "s" "an integer (shift)" } { "w" "an integer (wrap)" } { "y" integer } }
{ $description "Roll n by s bits to the left, wrapping around after w bits." }
{ $examples
    { $example "USING: math.bitfields.lib prettyprint ;" "1 -1 32 bitroll .b" "10000000000000000000000000000000" }
    { $example "USING: math.bitfields.lib prettyprint ;" "HEX: ffff0000 8 32 bitroll .h" "ff0000ff" }
} ;

