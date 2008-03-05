USING: help.markup help.syntax ;
IN: io.encodings

ABOUT: "encodings"

ARTICLE: "encodings" "I/O encodings"
"Many streams deal with bytes, rather than Unicode code points, at some level. The translation between these two things is specified by an encoding. To abstract this away from the programmer, Factor provides a system where these streams are associated with an encoding which is always used when the stream is read from or written to. For most purposes, an encoding descriptor consisting of a symbol is all that is needed when initializing a stream."
{ $subsection "encodings-constructors" }
{ $subsection "encodings-descriptors" }
{ $subsection "encodings-string" }
{ $subsection "encodings-protocol" } ;

ARTICLE: "encodings-constructors" "Constructing an encoded stream"
{ $subsection <encoder> }
{ $subsection <decoder> }
{ $subsection <encoder-duplex> } ;

HELP: <encoder> ( stream encoding -- newstream )
{ $values { "stream" "an output stream" }
    { "encoding" "an encoding descriptor" }
    { "newstream" "an encoded output stream" } }
{ $description "Wraps the given stream in a new stream using the given encoding for all output. The encoding descriptor can either be a class or an instance of something conforming to the " { $link "encodings-protocol" } "." } ;

HELP: <decoder> ( stream encoding -- newstream )
{ $values { "stream" "an input stream" }
    { "encoding" "an encoding descriptor" }
    { "newstream" "an encoded output stream" } }
{ $description "Wraps the given stream in a new stream using the given encoding for all input. The encoding descriptor can either be a class or an instance of something conforming to the " { $link "encodings-protocol" } "." } ;

HELP: <encoder-duplex> ( stream-in stream-out encoding -- duplex )
{ $values { "stream-in" "an input stream" }
    { "stream-out" "an output stream" }
    { "encoding" "an encoding descriptor" }
    { "duplex" "an encoded duplex stream" } }
{ $description "Wraps the given streams in an encoder or decoder stream, and puts them together in a duplex stream for input and output. If either input stream is already encoded, that encoding is stripped off before it is reencoded. The encoding descriptor must conform to the " { $link "encodings-protocol" } "." } ;

{ <encoder> <decoder> <encoder-duplex> } related-words

ARTICLE: "encodings-descriptors" "Encoding descriptors"
"An encoding descriptor is something which can be used for input or output streams to encode or decode files. It must conform to the " { $link "encodings-protocol" } ". Encodings which you can use include:"
{ $vocab-link "io.encodings.utf8" }
{ $vocab-link "io.encodings.ascii" }
{ $vocab-link "io.encodings.binary" }
{ $vocab-link "io.encodings.utf16" } ;
