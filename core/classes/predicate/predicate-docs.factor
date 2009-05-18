USING: generic help.markup help.syntax kernel kernel.private
namespaces sequences words arrays layouts help effects math
classes.private classes compiler.units ;
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
{ $values { "class" class } { "superclass" class } { "definition" { $quotation "( superclass -- ? )" } } }
{ $description "Defines a predicate class. This is the run time equivalent of " { $link POSTPONE: PREDICATE: } "." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "class" } ;

{ predicate-class define-predicate-class POSTPONE: PREDICATE: } related-words

HELP: predicate-class
{ $class-description "The class of predicate class words, defined by " { $link POSTPONE: PREDICATE: } " and documented in " { $link "predicates" } "." } ;
