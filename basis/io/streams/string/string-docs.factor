USING: help.markup help.syntax io strings quotations sequences ;
IN: io.streams.string

ARTICLE: "io.streams.string" "String streams"
"String streams:"
{ $subsections
    <string-reader>
    <string-writer>
}
"Utility combinators:"
{ $subsections
    with-string-reader
    with-string-writer
} ;

ABOUT: "io.streams.string"

HELP: <string-writer>
{ $values { "stream" "an output stream" } }
{ $description "Creates an output stream that collects text into a string buffer. The contents of the buffer can be obtained by executing " { $link >string } "." } ;

HELP: with-string-writer
{ $values { "quot" quotation } { "str" string } }
{ $description "Calls the quotation in a new dynamic scope with " { $link output-stream } " rebound to a new string writer. The accumulated string is output when the quotation returns." } ;

HELP: <string-reader>
{ $values { "str" string } { "stream" "an input stream" } }
{ $description "Creates a new stream for reading " { $snippet "str" } " from beginning to end." }
{ $notes "The implementation exploits the ability of string buffers to respond to the input stream protocol by reading characters from the end of the buffer." } ;

HELP: with-string-reader
{ $values { "str" string } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope with " { $link input-stream } " rebound to an input stream reading " { $snippet "str" } " from beginning to end." } ;
