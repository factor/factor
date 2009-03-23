USING: help.markup help.syntax strings io ;
IN: farkup

HELP: convert-farkup
{ $values { "string" string } { "string'" string } }
{ $description "Parse a Farkup string and convert it to an HTML string." } ;

HELP: write-farkup
{ $values { "string" string } }
{ $description "Parse a Farkup string and writes the resulting HTML to " { $link output-stream } "." } ;

HELP: parse-farkup
{ $values { "string" string } { "farkup" "a Farkup syntax tree node" } }
{ $description "Parses Farkup and outputs a tree of " { $link "farkup-ast" } "." } ;

HELP: (write-farkup)
{ $values { "farkup" "a Farkup syntax tree node" } { "xml" "an XML chunk" } }
{ $description "Converts a Farkup syntax tree node to XML." } ;

ARTICLE: "farkup-ast" "Farkup syntax tree nodes"
"The " { $link parse-farkup } " word outputs a tree of nodes corresponding to the Farkup syntax of the input string. This tree can be programatically traversed and mutated before being passed on to " { $link write-farkup } "."
{ $subsection heading1 }
{ $subsection heading2 }
{ $subsection heading3 }
{ $subsection heading4 }
{ $subsection strong }
{ $subsection emphasis }
{ $subsection superscript }
{ $subsection subscript }
{ $subsection inline-code }
{ $subsection paragraph }
{ $subsection list-item }
{ $subsection unordered-list }
{ $subsection ordered-list }
{ $subsection table }
{ $subsection table-row }
{ $subsection link }
{ $subsection image }
{ $subsection code } ;

ARTICLE: "farkup" "Farkup"
"The " { $vocab-link "farkup" } " vocabulary implements Farkup (Factor mARKUP), a simple markup language. Farkup was loosely based on the markup languages employed by MediaWiki and " { $url "http://reddit.com" } "."
$nl
"The main entry points for converting Farkup to HTML:"
{ $subsection convert-farkup }
{ $subsection write-farkup }
"The syntax tree of a piece of Farkup can also be inspected and modified:"
{ $subsection parse-farkup }
{ $subsection (write-farkup) }
{ $subsection "farkup-ast" } ;

ABOUT: "farkup"
