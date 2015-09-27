USING: help.syntax help.markup ;
IN: core-foundation.bundles

HELP: <CFBundle>
{ $values { "string" "a pathname string" } { "bundle" "a " { $snippet "CFBundle" } } }
{ $description "Creates a new " { $snippet "CFBundle" } "." } ;

HELP: load-framework
{ $values { "name" "a pathname string" } }
{ $description "Loads a Core Foundation framework." } ;
