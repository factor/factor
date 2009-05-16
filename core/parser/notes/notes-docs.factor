USING: help.markup help.syntax io ;
IN: parser.notes

HELP: parser-notes
{ $var-description "A boolean controlling whether the parser will print various notes. Switched on by default. If a source file is being run for its effect on " { $link output-stream } ", this variable should be switched off, to prevent parser notes from polluting the output." } ;

HELP: parser-notes?
{ $values { "?" "a boolean" } }
{ $description "Tests if the parser will print various notes and warnings. To disable parser notes, either set " { $link parser-notes } " to " { $link f } ", or pass the " { $snippet "-quiet" } " command line switch." } ;

