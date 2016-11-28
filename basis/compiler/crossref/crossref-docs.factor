USING: assocs help.markup help.syntax words ;
IN: compiler.crossref

HELP: compiled-crossref
{ $var-description "A hashtable that maps words to other words that depend on them. It also stores the types of the dependencies." } ;

HELP: load-dependencies
{ $values { "word" word } { "assoc" assoc } }
{ $description "Creates an assoc where keys are the words the word depends on and values are the dependency type." } ;

HELP: store-dependencies
{ $values { "word" word } { "assoc" assoc } }
{ $description "Stores the dependencies in 'assoc' in the word attributes named \"effect-dependencies\", \"conditional-dependencies\" and \"definition-dependencies\"." } ;
