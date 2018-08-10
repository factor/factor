USING: help.markup help.syntax strings ;
IN: multiline

HELP: parse-multiline-string
{ $values { "end-text" "a string delineating the end" } { "str" "the parsed string" } }
{ $description "Parses the input stream until the " { $snippet "end-text" } " is reached and returns the parsed text as a string." }
{ $notes "Used to implement " { $link \ \[[ } "." } ;

ARTICLE: "multiline" "Multiline"
"Writing new multiline parsing words:"
{ $subsections parse-multiline-string } ;

ABOUT: "multiline"
