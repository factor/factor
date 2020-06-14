USING: core-foundation.bundles help.syntax help.markup ;
IN: core-foundation.bundles+docs

HELP: <CFBundle>
{ $values { "string" "a pathname string" } { "bundle" "a " { $snippet "CFBundle" } } }
{ $description "Creates a new " { $snippet "CFBundle" } "." } ;

HELP: load-framework
{ $values { "name" "a pathname string" } }
{ $description "Loads a Core Foundation framework." } ;
