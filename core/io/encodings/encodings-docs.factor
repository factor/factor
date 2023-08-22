USING: help.markup help.syntax io quotations math sequences strings ;
IN: io.encodings

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

HELP: decode-char
{ $values { "stream" "an underlying input stream" }
    { "encoding" "An encoding descriptor tuple" } { "char/f" "a code point or " { $link f } } }
{ $contract "Reads a single code point from the underlying stream, interpreting it by the encoding. Returns " { $link f } " if the stream end is reached." }
$low-level-note ;

HELP: decode-until
{ $values
  { "seps" sequence }
  { "stream" "an input stream" }
  { "encoding" "an encoding descriptor" }
  { "string/f" { $maybe string } }
  { "sep/f" { $maybe "encountered separator" } }
}
{ $description "Decodes characters from the stream until one of the separators are encountered." } ;

HELP: encode-char
{ $values { "char" "a character" }
    { "stream" "an underlying output stream" }
    { "encoding" "an encoding descriptor" } }
{ $contract "Writes the code point to the underlying stream in the given encoding." }
$low-level-note ;

{ encode-char decode-char } related-words

HELP: decode-input
{ $values
    { "encoding" "an encoding descriptor" }
}
{ $description "Changes the encoding of the current input stream stored in the " { $link input-stream } " variable." } ;

HELP: encode-output
{ $values
    { "encoding" "an encoding descriptor" }
}
{ $description "Changes the encoding of the current output stream stored in the " { $link output-stream } " variable." } ;

HELP: re-decode
{ $values
    { "stream" "a stream" } { "encoding" "an encoding descriptor" }
    { "newstream" "a new stream" }
}
{ $description "Creates a new decoding stream with the supplied encoding descriptor from an existing stream by calling the " { $link <decoder> } " word." } ;

HELP: re-encode
{ $values
    { "stream" "a stream" } { "encoding" "an encoding descriptor" }
    { "newstream" "a new stream" }
}
{ $description "Creates a new encoding stream with the supplied encoding descriptor from an existing stream by calling the " { $link <encoder> } " word." } ;

{ re-decode re-encode } related-words

HELP: with-decoded-input
{ $values
    { "encoding" "an encoding descriptor" } { "quot" quotation }
}
{ $description "Creates a new decoding stream with the given encoding descriptor and calls the quotation with this stream set to the " { $link input-stream } " variable. The original decoder stream is restored after the quotation returns and the stream is kept open for future input operations." } ;

HELP: with-encoded-output
{ $values
    { "encoding" "an encoding descriptor" } { "quot" quotation }
}
{ $description "Creates a new encoder with the given encoding descriptor and calls the quotation using this encoder. The original encoder object is restored after the quotation returns and the stream is kept open for future output operations." } ;

HELP: replacement-char
{ $values
    { "value" integer }
}
{ $description "A code point that replaces input that could not be decoded. The presence of this character in the decoded data usually signifies an error." } ;

ARTICLE: "encodings-descriptors" "Encoding descriptors"
"An encoding descriptor is something which can be used with binary input or output streams to encode or decode bytes stored in a certain representation. It must conform to the " { $link "encodings-protocol" } ". Encodings which you can use are defined in the following vocabularies:"
{ $subsections
    "io.encodings.binary"
    "io.encodings.utf8"
}
{ $vocab-subsections
    { "UTF-16 encoding" "io.encodings.utf16" }
    { "UTF-32 encoding" "io.encodings.utf32" }
    { "Strict encodings" "io.encodings.strict" }
    { "8-bit encodings" "io.encodings.8-bit" }
    { "ASCII encoding" "io.encodings.ascii" }
}
{ $see-also "encodings-introduction" } ;

ARTICLE: "encodings-protocol" "Encoding protocol"
"There are two parts to implementing a new encoding. First, methods for creating an encoded or decoded stream must be provided. These have defaults, however, which wrap a stream in an encoder or decoder wrapper with the given encoding descriptor."
{ $subsections
    <encoder>
    <decoder>
}
"If an encoding might be contained in the code slot of an encoder or decoder tuple, then the following methods must be implemented to read or write one code point from a stream:"
{ $subsections
    decode-char
    encode-char
}
{ $see-also "encodings-introduction" } ;

ARTICLE: "encodings-constructors" "Manually constructing an encoded stream"
"The following words can be used to construct encoded streams. Note that they are usually not used directly, but rather by the stream constructors themselves. Most stream constructors take an encoding descriptor as a parameter and call these constructors internally."
{ $subsections
    <encoder>
    <decoder>
} ;

ARTICLE: "io.encodings" "I/O encodings"
"The " { $vocab-link "io.encodings" } " vocabulary provides utilities for encoding and decoding bytes that represent text. Encodings can be used in the following situations:"
{ $list
  "With binary input streams, to convert bytes to characters"
  "With binary output streams, to convert characters to bytes"
  "With byte arrays, to convert bytes to characters"
  "With strings, to convert characters to bytes"
}
{ $subsections
    "encodings-descriptors"
    "encodings-constructors"
    "io.encodings.string"
}
"New types of encodings can be defined:"
{ $subsections "encodings-protocol" }
"Setting encodings on the current streams:"
{ $subsections
    encode-output
    decode-input
}
"Setting encodings on streams:"
{ $subsections
    re-encode
    re-decode
}
"Combinators to change the encoding:"
{ $subsections
    with-encoded-output
    with-decoded-input
}
{ $see-also "encodings-introduction" } ;

ABOUT: "io.encodings"
