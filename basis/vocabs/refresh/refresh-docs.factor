USING: bootstrap.image help.markup help.syntax kernel strings ;
IN: vocabs.refresh

HELP: source-modified?
{ $values { "path" "a pathname string" } { "?" boolean } }
{ $description "Tests if the source file has been modified since it was last loaded. This compares the file's CRC32 checksum of the file's contents against the previously-recorded value." } ;

HELP: refresh
{ $values { "prefix" string } }
{ $description "Reloads source files and documentation belonging to loaded vocabularies whose names are prefixed by " { $snippet "prefix" } " which have been modified on disk." } ;

HELP: refresh-all
{ $description "Reloads source files and documentation for all loaded vocabularies which have been modified on disk." }
{ $notes
"After a fresh bootstrap if " { $link refresh-all } " reloads any vocabularies, then the boot image was outdated. You can generate a new boot image with " { $link make-my-image } " and bootstrap again." } ;

{ refresh refresh-all } related-words

ARTICLE: "vocabs.refresh" "Runtime code reloading"
"The " { $vocab-link "vocabs.refresh" } " vocabulary implements automatic reloading of changed source files."
$nl
"With the help of the " { $vocab-link "io.monitors" } " vocabulary, loaded source files across all vocabulary roots are monitored for changes on disk."
$nl
"If a change to a source file is detected, the next invocation of " { $link refresh-all } " will compare the file's checksum against its previous value, reloading the file if necessary. This takes advantage of the fact that the " { $vocab-link "source-files" } " vocabulary records CRC32 checksums of source files that have been parsed by " { $link "parser" } "."
$nl
"Words for reloading source files:"
{ $subsections
    refresh
    refresh-all
} ;

ABOUT: "vocabs.refresh"
