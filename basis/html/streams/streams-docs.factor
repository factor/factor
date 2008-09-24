IN: html.streams
USING: help.markup help.syntax kernel strings io io.styles
quotations ;

HELP: browser-link-href
{ $values { "presented" object } { "href" string } }
{ $contract "Outputs a link to a page displaying a presentation of the given object. This word is called when " { $link write-object } " is called on " { $link html-stream } " instances." } ;

HELP: html-stream
{ $class-description "A formatted output stream which emits HTML markup." } ;

HELP: <html-stream>
{ $values { "stream" "an output stream" } { "html-stream" html-stream } }
{ $description "Creates a new formatted output stream which emits HTML markup on " { $snippet "stream" } "." } ;

HELP: with-html-stream
{ $values { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope with " { $link output-stream } " rebound to an " { $link html-stream } " wrapping the current " { $link output-stream } "." }
{ $examples
    { $example
        "[ \"Hello\" { { font-style bold } } format nl ] with-html-stream"
        "<span style='font-style: normal; font-weight: bold; '>Hello</span><br/>"
    }
} ;

ARTICLE: "html.streams" "HTML streams"
"The " { $vocab-link "html.streams" } " vocabulary provides a stream which implements " { $link "styles" } " by writing HTML markup to the wrapped stream."
{ $subsection html-stream }
{ $subsection <html-stream> }
{ $subsection with-html-stream } ;

ABOUT: "html.streams"
