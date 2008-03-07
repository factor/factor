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
    { "encoding" "an encoding descriptor" } }
{ $description "Provides an input stream reading off the given byte array using the given encoding." } ;

HELP: <byte-writer>
{ $values { "encoding" "an encoding descriptor" }
    { "stream" "an output stream" } }
{ $description "Provides an output stream, putting things in the given encoding, storing everything written to it in a byte-array." } ;

HELP: with-byte-reader
{ $values { "encoding" "an encoding descriptor" }
    { "quot" quotation } { "byte-array" byte-array } }
{ $description "Calls the quotation in a new dynamic scope with " { $link stdio } " rebound to an input stream reading the byte array in the given encoding from beginning to end." } ;

HELP: with-byte-writer
{ $values  { "encoding" "an encoding descriptor" }
    { "quot" quotation }
    { "byte-array" byte-array } }
{ $description "Calls the quotation in a new dynamic scope with " { $link stdio } " rebound to a new byte array writer, putting things in the given encoding. The accumulated byte array is output when the quotation returns." } ;
