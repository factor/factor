! (c)2009 Joe Groff bsd license
USING: help.markup help.syntax ;
IN: method-chains

HELP: AFTER:
{ $syntax "AFTER: class generic
    implementation ;" }
{ $description "Defines a method on " { $snippet "generic" } " for " { $snippet "class" } " which executes the new " { $snippet "implementation" } " code after invoking the parent class method on " { $snippet "generic" } "." } ;

HELP: BEFORE:
{ $syntax "BEFORE: class generic
    implementation ;" }
{ $description "Defines a method on " { $snippet "generic" } " for " { $snippet "class" } " which executes the new " { $snippet "implementation" } " code, then invokes the parent class method on " { $snippet "generic" } "." } ;

ARTICLE: "method-chains" "Method chaining syntax"
"The " { $vocab-link "method-chains" } " vocabulary provides syntax for extending method implementations in class hierarchies." 
{ $subsections
    POSTPONE: AFTER:
    POSTPONE: BEFORE:
} ;

ABOUT: "method-chains"
