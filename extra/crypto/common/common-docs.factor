USING: help.markup help.syntax kernel math sequences quotations
crypto.common math.private ;

HELP: >32-bit
{ $values { "x" "an integer" } { "y" "an integer" } }
{ $description "Used to implement 32-bit integer overflow." } ;

HELP: >64-bit
{ $values { "x" "an integer" } { "y" "an integer" } }
{ $description "Used to implement 64-bit integer overflow." } ;

HELP: bitroll
{ $values { "x" "an integer (input)" } { "s" "an integer (shift)" } { "w" "an integer (wrap)" } { "y" "an integer" } }
{ $description "Roll n by s bits to the left, wrapping around after w bits." }
{ $examples
    { $example "1 -1 32 bitroll .b" "10000000000000000000000000000000" }
    { $example "HEX: ffff0000 8 32 bitroll .h" "ff0000ff" }
} ;


HELP: hex-string
{ $values { "seq" "a sequence" } { "str" "a string" } }
{ $description "Converts a sequence of values from 0-255 to a string of hex numbers from 0-ff." }
{ $examples
    { $example "B{ 1 2 3 4 } hex-string print" "01020304" }
}
{ $notes "Numbers are zero-padded on the left." } ;


