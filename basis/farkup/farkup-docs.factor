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
"The " { $link parse-farkup } " word outputs a tree of nodes corresponding to the Farkup syntax of the input string. This tree can be programmatically traversed and mutated before being passed on to " { $link write-farkup } "."
{ $subsections
    heading1
    heading2
    heading3
    heading4
    strong
    emphasis
    superscript
    subscript
    inline-code
    paragraph
    list-item
    unordered-list
    ordered-list
    table
    table-row
    link
    image
    code
} ;

ARTICLE: "farkup" "Farkup"
"The " { $vocab-link "farkup" } " vocabulary implements Farkup (Factor mARKUP), a simple markup language. Farkup was loosely based on the markup languages employed by MediaWiki and " { $url "http://reddit.com" } "."
$nl
"The main entry points for converting Farkup to HTML:"
{ $subsections
    convert-farkup
    write-farkup
}
"The syntax tree of a piece of Farkup can also be inspected and modified:"
{ $subsections
    parse-farkup
    (write-farkup)
    "farkup-ast"
} ;

ABOUT: "farkup"
