! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: tools.files

HELP: directory.
{ $values
    { "path" "a pathname string" }
}
{ $description "Prints information about all files in a directory to the output stream in a cross-platform way similar to the Unix " { $snippet "ls" } " command." } ;

ARTICLE: "tools.files" "Files tools"
"The " { $vocab-link "tools.files" } " vocabulary implements directory files and file-systems listing in a cross-platform way." $nl
"Listing a directory:"
{ $subsections directory. } ;

ABOUT: "tools.files"
