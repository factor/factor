USING: help.markup help.syntax sequences words ;
IN: stack-checker.known-words

HELP: define-primitive
{ $values { "word" word } { "inputs" sequence } { "outputs" sequence } }
{ $description "Marks the word as a primitive whose input and output types must be the given ones." } ;
