USING: help.markup help.syntax sequences ;
IN: base64

HELP: >base64
{ $values { "seq" sequence } { "base64" "a string of base64 characters" } }
{ $description "Converts a sequence to its Base64 representation by taking six bits at a time as an index into a lookup table containing alphanumerics, '+', and '/'. The result is padded with '=' if the input was not a multiple of six bits." }
{ $examples
    { $example "USING: prettyprint base64 strings ;" "\"The monorail is a free service.\" >base64 >string ." "\"VGhlIG1vbm9yYWlsIGlzIGEgZnJlZSBzZXJ2aWNlLg==\"" }
}
{ $see-also >base64-lines base64> } ;

HELP: >base64-lines
{ $values { "seq" sequence } { "base64" "a string of base64 characters" } }
{ $description "Converts a sequence to its Base64 representation by taking six bits at a time as an index into a lookup table containing alphanumerics, '+', and '/'. The result is padded with '=' if the input was not a multiple of six bits. A crlf is inserted for every 76 characters of output." }
{ $see-also >base64 base64> } ;


HELP: base64>
{ $values { "base64" "a string of base64 characters" } { "seq" sequence } }
{ $description "Converts a string in Base64 encoding back into its binary representation." }
{ $examples
    { $example "USING: prettyprint base64 strings ;" "\"VGhlIG1vbm9yYWlsIGlzIGEgZnJlZSBzZXJ2aWNlLg==\" base64> >string ." "\"The monorail is a free service.\"" }
}
{ $notes "This word will throw if the input string contains characters other than those allowed in base64 encodings." }
{ $see-also >base64 >base64-lines } ;

HELP: encode-base64
{ $description "Reads the standard input and writes it to standard output encoded in base64." } ;

HELP: decode-base64
{ $description "Reads the standard input and decodes it, writing to standard output." } ;

HELP: encode-base64-lines
{ $description "Reads the standard input and writes it to standard output encoded in base64 with a crlf every 76 characters." } ;

ARTICLE: "base64" "Base64 conversions"
"The " { $vocab-link "base64" } " vocabulary implements conversions of sequences to printable characters in Base64. These plain-text representations of binary data may be passed around and converted back to binary data later." $nl
"Converting to and from Base64 as strings:"
{ $subsections
    >base64
    >base64-lines
    base64>
}
"Using Base64 from streams:"
{ $subsections
    encode-base64
    encode-base64-lines
    decode-base64
} ;

ABOUT: "base64"
