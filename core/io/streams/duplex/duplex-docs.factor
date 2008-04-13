USING: help.markup help.syntax io continuations ;
IN: io.streams.duplex

ARTICLE: "io.streams.duplex" "Duplex streams"
"Duplex streams combine an input stream and an output stream into a bidirectional stream."
{ $subsection duplex-stream }
{ $subsection <duplex-stream> }
{ $subsection check-closed } ;

ABOUT: "io.streams.duplex"

HELP: duplex-stream
{ $class-description "A bidirectional stream wrapping an input and output stream." } ;

HELP: <duplex-stream>
{ $values { "in" "an input stream" } { "out" "an output stream" } { "stream" " a duplex stream" } }
{ $description "Creates a duplex stream. Writing to a duplex stream will write to " { $snippet "out" } ", and reading from a duplex stream will read from " { $snippet "in" } ". Closing a duplex stream closes both the input and output streams." } ;

HELP: stream-closed-twice
{ $error-description "This error is thrown when performing an I/O operation on a " { $link duplex-stream } " which has been closed with " { $link dispose } "." } ;
