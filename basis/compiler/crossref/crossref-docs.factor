USING: assocs help.markup help.syntax kernel sequences words ;
IN: compiler.crossref

HELP: compiled-crossref
{ $var-description "A hashtable that maps words to other words that depend on them and their dependency types." } ;

HELP: delete-compiled-xref
{ $values { "word" word } }
{ $description "Deletes cross-referencing data for a word. Used when the optimizing compiler forgets a word." } ;

HELP: dependencies-satisfied?
{ $values { "word" word } { "cache" assoc } { "?" boolean } }
{ $description "Checks if all the words dependencies are satisfied or not." } ;

HELP: load-dependencies
{ $values { "word" word } { "seq" sequence } }
{ $description "Outputs a sequence of the words dependencies." } ;

HELP: remove-xref
{ $values { "word" word } { "dependencies" sequence } { "crossref" assoc } }
{ $description "Removes a set of dependencies from the cross referencing table." } ;

HELP: store-dependencies
{ $values { "word" word } { "assoc" assoc } }
{ $description "Stores the dependencies in 'assoc' in the word attribute \"dependencies\"." } ;

ARTICLE: "compiler.crossref"  "Crossreferencing word dependencies."
"A vocab that keeps track on how words depends on each other and their dependence types." ;

ABOUT: "compiler.crossref"
