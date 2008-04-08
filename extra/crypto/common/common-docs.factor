USING: help.markup help.syntax kernel math sequences quotations
math.private ;
IN: crypto.common

HELP: hex-string
{ $values { "seq" "a sequence" } { "str" "a string" } }
{ $description "Converts a sequence of values from 0-255 to a string of hex numbers from 0-ff." }
{ $examples
    { $example "USING: crypto.common io ;" "B{ 1 2 3 4 } hex-string print" "01020304" }
}
{ $notes "Numbers are zero-padded on the left." } ;


