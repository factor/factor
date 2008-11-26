! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string strings ;
IN: io.files.listing

HELP: directory.
{ $values
     { "path" "a pathname string" }
}
{ $description "Prints information about all files in a directory to the output stream in a cross-platform way similar to the Unix " { $snippet "ls" } " command." } ;

ARTICLE: "io.files.listing" "Listing files"
"The " { $vocab-link "io.files.listing" } " vocabulary implements directory file listing in a cross-platform way." $nl
"Listing a directory:"
{ $subsection directory. } ;

ABOUT: "io.files.listing"
