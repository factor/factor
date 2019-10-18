USING: help.markup help.syntax sequences words ;
IN: stack-checker.known-words

HELP: infer-special
{ $values { "word" word } }
{ $description "Performs inferencing of a word with the \"special\" property set." } ;

HELP: infer-ndip
{ $values { "word" word } { "n" "the dip depth" } }
{ $description "Performs inferencing for one of the dip words." } ;

HELP: define-primitive
{ $values { "word" word } { "inputs" sequence } { "outputs" sequence } }
{ $description "Marks the word as a primitive whose input and output types must be the given ones." } ;
