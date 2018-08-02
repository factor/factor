USING: help.syntax help.markup ;
IN: core-foundation.urls

HELP: <CFFileSystemURL>
{ $values { "string" "a pathname string" } { "dir?" "a boolean indicating if the pathname is a directory" } { "url" "a " { $snippet "CFurl"} } }
{ $description "Creates a new " { $snippet "CFurl"} " pointing to the given local pathname." } ;

HELP: <CFURL>
{ $values { "string" "a URL string" } { "url" "a " { $snippet "CFurl"} } }
{ $description "Creates a new " { $snippet "CFurl"} "." } ;
