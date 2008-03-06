USING: help.markup help.syntax ;
IN: io.encodings

ABOUT: "encodings"

ARTICLE: "io.encodings" "I/O encodings"
"Many streams deal with bytes, rather than Unicode code points, at some level. The translation between these two things is specified by an encoding. To abstract this away from the programmer, Factor provides a system where these streams are associated with an encoding which is always used when the stream is read from or written to. For most purposes, an encoding descriptor consisting of a symbol is all that is needed when initializing a stream."
{ $subsection "encodings-constructors" }
{ $subsection "encodings-descriptors" }
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
"An encoding descriptor is something which can be used for input or output streams to encode or decode files. It must conform to the " { $link "encodings-protocol" } ". Encodings which you can use are defined in the following vocabularies:"
$nl { $vocab-link "io.encodings.utf8" }
$nl { $vocab-link "io.encodings.ascii" }
$nl { $vocab-link "io.encodings.binary" }
$nl { $vocab-link "io.encodings.utf16" } ;

ARTICLE: "encodings-protocol" "Encoding protocol"
"An encoding descriptor must implement the following methods. The methods are implemented on tuple classes by instantiating the class and calling the method again."
{ $subsection decode-step }
{ $subsection init-decoder }
{ $subsection stream-write-encoded } ;

HELP: decode-step ( buf char encoding -- )
{ $values { "buf" "A string buffer which characters can be pushed to" }
    { "char" "An octet which is read from a stream" }
    { "encoding" "An encoding descriptor tuple" } }
{ $description "A single step in the decoding process must be defined for the decoding descriptor. When each octet is read, this word is called, and depending on the decoder's internal state, something may be pushed to the buffer or the state may change. This should not be used directly." } ;

HELP: stream-write-encoded ( string stream encoding -- )
{ $values { "string" "a string" }
    { "stream" "an output stream" }
    { "encoding" "an encoding descriptor" } }
{ $description "Encodes the string with the given encoding descriptor, outputing the result to the given stream. This should not be used directly." } ;

HELP: init-decoder ( stream encoding -- encoding )
{ $values { "stream" "an input stream" }
    { "encoding" "an encoding descriptor" } }
{ $description "Initializes the decoder tuple's state. The stream is exposed so that it can be read, eg for a BOM. This should not be used directly." } ;

{ init-decoder decode-step stream-write-encoded } related-words
