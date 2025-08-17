USING: help.markup help.syntax kernel strings io io.styles
quotations xml.data ;
IN: io.streams.html

HELP: url-of
{ $values { "object" object } { "url" string } }
{ $contract "Outputs a link to a page displaying a presentation of the given object. This word is called when " { $link write-object } " is called on " { $link html-writer } " instances." } ;

HELP: html-writer
{ $class-description "A formatted output stream which accumulates HTML markup as " { $vocab-link "xml.data" } " types. The " { $slot "data" } " slot contains a sequence with all markup so far." } ;

HELP: <html-writer>
{ $values { "html-writer" html-writer } }
{ $description "Creates a new formatted output stream which accumulates HTML markup in its " { $snippet "data" } " slot." } ;

HELP: with-html-writer
{ $values { "quot" quotation } { "xml" xml-chunk } }
{ $description "Calls the quotation in a new dynamic scope with " { $link output-stream } " rebound to an " { $link html-writer } ". When the quotation returns, outputs the accumulated HTML markup." }
{ $examples
    { $example
        "USING: io io.styles io.streams.html xml.writer ;"
        "[ \"Hello\" { { font-style bold } } format nl ] with-html-writer write-xml"
        "<span style=\"font-style: normal; font-weight: bold; \">Hello</span><br/>"
    }
} ;

ARTICLE: "io.streams.html" "HTML streams"
"The " { $vocab-link "io.streams.html" } " vocabulary provides a stream which implements " { $link "io.styles" } " by constructing HTML markup in the form of " { $vocab-link "xml.data" } " types."
{ $subsections
    html-writer
    <html-writer>
    with-html-writer
} ;

ABOUT: "io.streams.html"
