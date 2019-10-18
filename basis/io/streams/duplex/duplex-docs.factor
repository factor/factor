USING: help.markup help.syntax io continuations quotations ;
IN: io.streams.duplex

ARTICLE: "io.streams.duplex" "Duplex streams"
"Duplex streams combine an input stream and an output stream into a bidirectional stream."
{ $subsections
    duplex-stream
    <duplex-stream>
}
"A pair of combinators for rebinding both default streams at once:"
{ $subsections
    with-stream
    with-stream*
} ;

ABOUT: "io.streams.duplex"

HELP: duplex-stream
{ $class-description "A bidirectional stream wrapping an input and output stream." } ;

HELP: <duplex-stream>
{ $values { "in" "an input stream" } { "out" "an output stream" } { "duplex-stream" duplex-stream } }
{ $description "Creates a duplex stream. Writing to a duplex stream will write to " { $snippet "out" } ", and reading from a duplex stream will read from " { $snippet "in" } ". Closing a duplex stream closes both the input and output streams." } ;

HELP: with-stream
{ $values { "stream" duplex-stream } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope, with both " { $link input-stream } " and " { $link output-stream } " rebound to " { $snippet "stream" } ", which must be a duplex stream. The stream is closed if the quotation returns or throws an error." } ;

HELP: with-stream*
{ $values { "stream" duplex-stream } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope, with both " { $link input-stream } " and " { $link output-stream } " rebound to " { $snippet "stream" } ", which must be a duplex stream." }
{ $notes "This word does not close the stream. Compare with " { $link with-stream } "." } ;

HELP: <encoder-duplex>
{ $values { "stream-in" "an input stream" }
    { "stream-out" "an output stream" }
    { "encoding" "an encoding descriptor" }
    { "duplex" "an encoded duplex stream" } }
{ $description "Wraps the given streams in an encoder or decoder stream, and puts them together in a duplex stream for input and output. If either input stream is already encoded, that encoding is stripped off before it is reencoded. The encoding descriptor must conform to the " { $link "encodings-protocol" } "." }
$low-level-note ;
