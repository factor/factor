IN: make
USING: help.markup help.syntax quotations sequences math.parser
kernel ;

ARTICLE: "namespaces-make" "Making sequences with variables"
"The " { $vocab-link "make" } " vocabulary implements a facility for constructing sequences by holding an accumulator sequence in a variable. Storing the accumulator sequence in a variable rather than the stack may allow code to be written with less stack manipulation."
{ $subsection make }
{ $subsection , }
{ $subsection % }
{ $subsection # }
"The accumulator sequence can be accessed directly:"
{ $subsection building } ;

ABOUT: "namespaces-make"

HELP: building
{ $var-description "Temporary mutable growable sequence holding elements accumulated so far by " { $link make } "." } ;

HELP: make
{ $values { "quot" quotation } { "exemplar" sequence } { "seq" "a new sequence" } }
{ $description "Calls the quotation in a new " { $emphasis "dynamic scope" } ". The quotation and any words it calls can execute the " { $link , } " and " { $link % } " words to accumulate elements. When the quotation returns, all accumulated elements are collected into a sequence with the same type as " { $snippet "exemplar" } "." }
{ $examples { $example "USING: namespaces prettyprint ;" "[ 1 , 2 , 3 , ] { } make ." "{ 1 2 3 }" } } ;

HELP: ,
{ $values { "elt" object } }
{ $description "Adds an element to the end of the sequence being constructed by " { $link make } "." } ;

HELP: %
{ $values { "seq" sequence } }
{ $description "Appends a sequence to the end of the sequence being constructed by " { $link make } "." } ;
