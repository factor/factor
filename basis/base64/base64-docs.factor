USING: help.markup help.syntax kernel math sequences ;
IN: base64

HELP: >base64
{ $values { "seq" sequence } { "base64" "a string of base64 characters" } }
{ $description "Converts a sequence to its base64 representation by taking six bits at a time as an index into a lookup table containing alphanumerics, '+', and '/'.  The result is padded with '=' if the input was not a multiple of six bits." }
{ $examples
    { $example "USING: prettyprint base64 strings ;" "\"The monorail is a free service.\" >base64 >string ." "\"VGhlIG1vbm9yYWlsIGlzIGEgZnJlZSBzZXJ2aWNlLg==\"" }
}
{ $see-also base64> } ;

HELP: base64>
{ $values { "base64" "a string of base64 characters" } { "seq" sequence } }
{ $description "Converts a string in base64 encoding back into its binary representation." }
{ $examples
    { $example "USING: prettyprint base64 strings ;" "\"VGhlIG1vbm9yYWlsIGlzIGEgZnJlZSBzZXJ2aWNlLg==\" base64> >string ." "\"The monorail is a free service.\"" }
}
{ $notes "This word will throw if the input string contains characters other than those allowed in base64 encodings." }
{ $see-also >base64 } ;

ARTICLE: "base64" "Base 64 conversions"
"The " { $vocab-link "base64" } " vocabulary implements conversions of sequences to printable characters in base 64. These plain-text representations of binary data may be passed around and converted back to binary data later." $nl
"Converting to base 64:"
{ $subsection >base64 }
"Converting back to binary:"
{ $subsection base64> } ;

ABOUT: "base64"
