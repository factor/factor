USING: help.syntax help.markup io byte-arrays quotations ;
IN: io.streams.byte-array

ABOUT: "io.streams.byte-array"

ARTICLE: "io.streams.byte-array" "Byte-array streams"
"Byte array streams:"
{ $subsection <byte-reader> }
{ $subsection <byte-writer> }
"Utility combinators:"
{ $subsection with-byte-reader }
{ $subsection with-byte-writer } ;

HELP: <byte-reader>
{ $values { "byte-array" byte-array }
    { "encoding" "an encoding descriptor" }
    { "stream" "a new byte reader" } }
{ $description "Creates an input stream reading from a byte array using an encoding." } ;

HELP: <byte-writer>
{ $values { "encoding" "an encoding descriptor" }
    { "stream" "a new byte writer" } }
{ $description "Creates an output stream writing data to a byte array using an encoding." } ;

HELP: with-byte-reader
{ $values { "encoding" "an encoding descriptor" }
    { "quot" quotation } { "byte-array" byte-array } }
{ $description "Calls the quotation in a new dynamic scope with " { $link input-stream } " rebound to an input stream for reading from a byte array using an encoding." } ;

HELP: with-byte-writer
{ $values  { "encoding" "an encoding descriptor" }
    { "quot" quotation }
    { "byte-array" byte-array } }
{ $description "Calls the quotation in a new dynamic scope with " { $link output-stream } " rebound to an output stream writing data to a byte array using an encoding." } ;
