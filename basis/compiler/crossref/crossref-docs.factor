USING: assocs help.markup help.syntax words ;
IN: compiler.crossref

HELP: load-dependencies
{ $values { "word" word } { "assoc" assoc } }
{ $description "Creates an assoc where keys are the words the word depends on and values are the dependency type." } ;
