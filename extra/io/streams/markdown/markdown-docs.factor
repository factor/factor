USING: help.markup help.syntax kernel strings io io.styles
quotations xml.data ;

IN: io.streams.markdown

HELP: markdown-writer
{ $class-description "A formatted output stream which accumulates Markdown markup as " { $link string } " types. The " { $slot "data" } " slot contains a sequence with all markup so far." } ;

HELP: <markdown-writer>
{ $values { "markdown-writer" markdown-writer } }
{ $description "Creates a new formatted output stream which accumulates Markdown markup in its " { $snippet "data" } " slot." } ;

HELP: with-markdown-writer
{ $values { "quot" quotation } { "str" string } }
{ $description "Calls the quotation in a new dynamic scope with " { $link output-stream } " rebound to an " { $link markdown-writer } ". When the quotation returns, outputs the accumulated Markdown markup." }
{ $examples
    { $example
        "USING: io io.styles io.streams.markdown prettyprint ;"
        "[ \"Hello\" { { font-style bold } } format nl ] with-markdown-writer ."
        "\"**Hello**\\n\\n\""
    }
} ;

ARTICLE: "io.streams.markdown" "Markdown streams"
"The " { $vocab-link "io.streams.markdown" } " vocabulary provides a stream which implements " { $link "io.styles" } " by constructing Markdown markup in the form of " { $link string } " types."
{ $subsections
    markdown-writer
    <markdown-writer>
    with-markdown-writer
} ;

ABOUT: "io.streams.markdown"
