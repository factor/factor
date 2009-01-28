USING: help.syntax help.markup ;
IN: core-foundation.urls

HELP: <CFFileSystemURL>
{ $values { "string" "a pathname string" } { "dir?" "a boolean indicating if the pathname is a directory" } { "url" "a " { $snippet "CFURL" } } }
{ $description "Creates a new " { $snippet "CFURL" } " pointing to the given local pathname." } ;

HELP: <CFURL>
{ $values { "string" "a URL string" } { "url" "a " { $snippet "CFURL" } } }
{ $description "Creates a new " { $snippet "CFURL" } "." } ;
