USING: help.markup help.syntax strings ;
IN: vocabs.refresh

HELP: source-modified?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if the source file has been modified since it was last loaded. This compares the file's CRC32 checksum of the file's contents against the previously-recorded value." } ;

HELP: refresh
{ $values { "prefix" string } }
{ $description "Reloads source files and documentation belonging to loaded vocabularies whose names are prefixed by " { $snippet "prefix" } " which have been modified on disk." } ;

HELP: refresh-all
{ $description "Reloads source files and documentation for all loaded vocabularies which have been modified on disk." } ;

{ refresh refresh-all } related-words

ARTICLE: "vocabs.refresh" "Runtime code reloading"
"Reloading source files changed on disk:"
{ $subsection refresh }
{ $subsection refresh-all } ;

ABOUT: "vocabs.refresh"
