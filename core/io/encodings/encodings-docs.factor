USING: help.markup help.syntax ;
IN: io.encodings

ABOUT: "encodings"

ARTICLE: "io.encodings" "I/O encodings"
"Many streams deal with bytes, rather than Unicode code points, at some level. The translation between these two things is specified by an encoding. To abstract this away from the programmer, Factor provides a system where these streams are associated with an encoding which is always used when the stream is read from or written to. For most purposes, an encoding descriptor consisting of a symbol is all that is needed when initializing a stream."
{ $subsection "encodings-constructors" }
{ $subsection "encodings-descriptors" }
{ $subsection "encodings-protocol" } ;

ARTICLE: "encodings-constructors" "Constructing an encoded stream"
"The following words can be used to construct encoded streams. Note that they are usually not used directly, but rather by the stream constructors themselves."
{ $subsection <encoder> }
{ $subsection <decoder> }
{ $subsection <encoder-duplex> } ;

HELP: <encoder>
{ $values { "stream" "an output stream" }
    { "encoding" "an encoding descriptor" }
    { "newstream" "an encoded output stream" } }
{ $description "Wraps the given stream in a new stream using the given encoding for all output. The encoding descriptor can either be a class or an instance of something conforming to the " { $link "encodings-protocol" } "." } ;

HELP: <decoder>
{ $values { "stream" "an input stream" }
    { "encoding" "an encoding descriptor" }
    { "newstream" "an encoded output stream" } }
{ $description "Wraps the given stream in a new stream using the given encoding for all input. The encoding descriptor can either be a class or an instance of something conforming to the " { $link "encodings-protocol" } "." } ;

HELP: <encoder-duplex>
{ $values { "stream-in" "an input stream" }
    { "stream-out" "an output stream" }
    { "encoding" "an encoding descriptor" }
    { "duplex" "an encoded duplex stream" } }
{ $description "Wraps the given streams in an encoder or decoder stream, and puts them together in a duplex stream for input and output. If either input stream is already encoded, that encoding is stripped off before it is reencoded. The encoding descriptor must conform to the " { $link "encodings-protocol" } "." } ;

{ <encoder> <decoder> <encoder-duplex> } related-words

ARTICLE: "encodings-descriptors" "Encoding descriptors"
"An encoding descriptor is something which can be used for input or output streams to encode or decode files. It must conform to the " { $link "encodings-protocol" } ". Encodings which you can use are defined in the following vocabularies:"
{ $vocab-subsection "io.encodings.utf8" }
{ $vocab-subsection "io.encodings.ascii" }
{ $vocab-subsection "io.encodings.8-bit" }
{ $vocab-subsection "io.encodings.binary" }
{ $vocab-subsection "io.encodings.utf16" } ;

ARTICLE: "encodings-protocol" "Encoding protocol"
"An encoding descriptor must implement the following methods. The methods are implemented on tuple classes by instantiating the class and calling the method again."
{ $subsection decode-char }
{ $subsection encode-char }
"Optionally, an encoding can override the constructor words:" 
{ $subsection <encoder> }
{ $subsection <decoder> } ;

HELP: decode-char
{ $values { "stream" "an underlying input stream" }
    { "encoding" "An encoding descriptor tuple" } { "char/f" "a code point or " { $link f } } }
{ $description "Reads a single code point from the underlying stream, interpreting it by the encoding. This should not be used directly." } ;

HELP: encode-char
{ $values { "char" "a character" }
    { "stream" "an underlying output stream" }
    { "encoding" "an encoding descriptor" } }
{ $description "Writes the code point in the encoding to the underlying stream given. This should not be used directly." } ;

{ encode-char decode-char } related-words
