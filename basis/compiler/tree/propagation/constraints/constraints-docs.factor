USING: help.markup help.syntax kernel sequences ;
IN: compiler.tree.propagation.constraints

HELP: class-constraint
{ $class-description "A class constraint." } ;

HELP: constraints
{ $var-description "A " { $link sequence } " of assocs. They maps constraints to constraints ('A implies B')." } ;

HELP: equivalence
{ $var-description "An equivalence constraint." } ;

HELP: implication
{ $class-description "An implication constraint." } ;

HELP: interval-constraint
{ $class-description "An interval constraint." } ;

HELP: literal-constraint
{ $class-description "A literal constraint" } ;

HELP: satisfied?
{ $values { "constraint" "a constraint" } { "?" boolean } }
{ $description "satisfied? is inaccurate. It's just used to prevent infinite loops so its only implemented for true-constraints and false-constraints." } ;

ARTICLE: "compiler.tree.propagation.constraints" "Support for predicated value info"
"A constraint is a statement about a value."
$nl
"Boolean constraints:"
{ $subsections true-constraint true-constraint }
"Utilities:"
{ $subsections t--> f--> } ;

ABOUT: "compiler.tree.propagation.constraints"
