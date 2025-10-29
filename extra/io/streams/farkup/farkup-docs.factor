USING: help.markup help.syntax kernel strings io io.styles
quotations xml.data ;

IN: io.streams.farkup

HELP: farkup-writer
{ $class-description "A formatted output stream which accumulates Farkup markup as " { $link string } " types. The " { $slot "data" } " slot contains a sequence with all markup so far." } ;

HELP: <farkup-writer>
{ $values { "farkup-writer" farkup-writer } }
{ $description "Creates a new formatted output stream which accumulates Farkup markup in its " { $snippet "data" } " slot." } ;

HELP: with-farkup-writer
{ $values { "quot" quotation } { "str" string } }
{ $description "Calls the quotation in a new dynamic scope with " { $link output-stream } " rebound to an " { $link farkup-writer } ". When the quotation returns, outputs the accumulated Farkup markup." }
{ $examples
    { $example
        "USING: io io.styles io.streams.farkup prettyprint ;"
        "[ \"Hello\" { { font-style bold } } format nl ] with-farkup-writer ."
        "\"*Hello*\\n\\n\""
    }
} ;

ARTICLE: "io.streams.farkup" "Farkup streams"
"The " { $vocab-link "io.streams.farkup" } " vocabulary provides a stream which implements " { $link "io.styles" } " by constructing Farkup markup in the form of " { $link string } " types."
{ $subsections
    farkup-writer
    <farkup-writer>
    with-farkup-writer
} ;

ABOUT: "io.streams.farkup"
