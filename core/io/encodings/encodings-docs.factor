USING: help.markup help.syntax ;
IN: io.encodings

ABOUT: "io.encodings"

ARTICLE: "io.encodings" "I/O encodings"
"Bytes can't be understood in isolation as text. They must be interpreted under a certain encoding. Factor provides utilities for dealing with encoded text by declaring that a stream has a particular encoding, and utilities to encode and decode strings."
{ $subsection "encodings-constructors" }
{ $subsection "encodings-descriptors" }
{ $subsection "encodings-protocol" } ;

ARTICLE: "encodings-constructors" "Manually constructing an encoded stream"
"The following words can be used to construct encoded streams. Note that they are usually not used directly, but rather by the stream constructors themselves. Most stream constructors take an encoding descriptor as a parameter and internally call these constructors."
{ $subsection <encoder> }
{ $subsection <decoder> }
{ $subsection <encoder-duplex> } ;

HELP: <encoder>
{ $values { "stream" "an output stream" }
    { "encoding" "an encoding descriptor" }
    { "newstream" "an encoded output stream" } }
{ $description "Wraps the given stream in a new stream using the given encoding for all output. The encoding descriptor can either be a class or an instance of something conforming to the " { $link "encodings-protocol" } "." }
$low-level-note ;

HELP: <decoder>
{ $values { "stream" "an input stream" }
    { "encoding" "an encoding descriptor" }
    { "newstream" "an encoded output stream" } }
{ $description "Wraps the given stream in a new stream using the given encoding for all input. The encoding descriptor can either be a class or an instance of something conforming to the " { $link "encodings-protocol" } "." }
$low-level-note ;

HELP: <encoder-duplex>
{ $values { "stream-in" "an input stream" }
    { "stream-out" "an output stream" }
    { "encoding" "an encoding descriptor" }
    { "duplex" "an encoded duplex stream" } }
{ $description "Wraps the given streams in an encoder or decoder stream, and puts them together in a duplex stream for input and output. If either input stream is already encoded, that encoding is stripped off before it is reencoded. The encoding descriptor must conform to the " { $link "encodings-protocol" } "." }
$low-level-note ;

{ <encoder> <decoder> <encoder-duplex> } related-words

ARTICLE: "encodings-descriptors" "Encoding descriptors"
"An encoding descriptor is something which can be used for input or output streams to encode or decode files. It must conform to the " { $link "encodings-protocol" } ". Encodings which you can use are defined in the following vocabularies:"
{ $vocab-subsection "ASCII" "io.encodings.ascii" }
{ $vocab-subsection "Binary" "io.encodings.binary" }
{ $vocab-subsection "Strict encodings" "io.encodings.strict" }
{ $vocab-subsection "8-bit encodings" "io.encodings.8-bit" }
{ $vocab-subsection "UTF-8" "io.encodings.utf8" }
{ $vocab-subsection "UTF-16" "io.encodings.utf16" }
{ $see-also "encodings-introduction" } ;

ARTICLE: "encodings-protocol" "Encoding protocol"
"There are two parts to implementing a new encoding. First, methods for creating an encoded or decoded stream must be provided. These have defaults, however, which wrap a stream in an encoder or decoder wrapper with the given encoding descriptor."
{ $subsection <encoder> }
{ $subsection <decoder> }
"If an encoding might be contained in the code slot of an encoder or decoder tuple, then the following methods must be implemented to read or write one code point from a stream:"
{ $subsection decode-char }
{ $subsection encode-char }
{ $see-also "encodings-introduction" } ;

HELP: decode-char
{ $values { "stream" "an underlying input stream" }
    { "encoding" "An encoding descriptor tuple" } { "char/f" "a code point or " { $link f } } }
{ $contract "Reads a single code point from the underlying stream, interpreting it by the encoding." }
$low-level-note ;

HELP: encode-char
{ $values { "char" "a character" }
    { "stream" "an underlying output stream" }
    { "encoding" "an encoding descriptor" } }
{ $contract "Writes the code point in the encoding to the underlying stream given." }
$low-level-note ;

{ encode-char decode-char } related-words
