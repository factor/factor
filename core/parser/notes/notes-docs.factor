USING: help.markup help.syntax io parser.notes ;
IN: parser.notes

HELP: parser-quiet?
{ $var-description "A boolean controlling whether the parser will print various notes. Switched on by default. If a source file is being run for its effect on " { $link output-stream } ", this variable should remain switched on, to prevent parser notes from polluting the output." } ;
