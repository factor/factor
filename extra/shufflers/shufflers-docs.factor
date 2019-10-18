USING: shufflers help.syntax help.markup ;

HELP: SHUFFLE:
{ $syntax "SHUFFLE: alphabet #" }
{ $values { "alphabet" "an alphabet of unique letters" } { "#" "the maximum length" } }
{ $description "Defines stack shufflers of the form abc-bcba where 'abc' describes the inputs and 'bcba' describes the outputs. Given a stack of 1 2 3, this returns 2 3 2 1. The stack shufflers defined are put in the current vocab with the suffix '.shuffle' appended." }
{ $examples
"SHUFFLE: abcd 6\n"
": 4drop abcd- ;\n"
": 2over abcd-abcdab ;\n"
": 2swap abcd-cdab ;\n"
": 3dup abc-abcabc ;\n" } ;
