IN: html
USING: help.markup help.syntax strings ;

HELP: simple-page
{ $values { "title" string } { "head" "XML data" } { "body" "XML data" } }
{ $description "Constructs a simple XHTML page with a " { $snippet "head" } " and " { $snippet "body" } " tag. The given XML data is spliced into the two child tags, and a title is also added to the head tag." } ;