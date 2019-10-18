USING: generic help.markup help.syntax kernel kernel.private
namespaces sequences words arrays layouts help effects math
layouts classes.private classes ;
IN: classes.predicate

ARTICLE: "predicates" "Predicate classes"
"Predicate classes allow fine-grained control over method dispatch."
{ $subsection POSTPONE: PREDICATE: }
{ $subsection define-predicate-class }
"The set of predicate classes is a class:"
{ $subsection predicate-class }
{ $subsection predicate-class? } ;

ABOUT: "predicates"

HELP: define-predicate-class
{ $values { "superclass" class } { "class" class } { "definition" "a quotation with stack effect " { $snippet "( superclass -- ? )" } } }
{ $description "Defines a predicate class." } ;

{ predicate-class define-predicate-class POSTPONE: PREDICATE: } related-words

HELP: predicate-class
{ $class-description "The class of predicate class words, defined by " { $link POSTPONE: PREDICATE: } " and documented in " { $link "predicates" } "." } ;
