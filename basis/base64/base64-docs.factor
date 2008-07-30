USING: help.markup help.syntax kernel math ;
IN: base64

HELP: >base64
{ $values { "seq" "a sequence" } { "base64" "a string of base64 characters" } }
{ $description "Converts a sequence to its base64 representation by taking six bits at a time as an index into a lookup table containing alphanumerics, '+', and '/'.  The result is padded with '=' if the input was not a multiple of six bits." }
{ $examples
    { $unchecked-example "\"The monorail is a free service.\" >base64 ." "VGhlIG1vbm9yYWlsIGlzIGEgZnJlZSBzZXJ2aWNlLg==" }
}
{ $see-also base64> } ;

HELP: base64>
{ $values { "base64" "a string of base64 characters" } { "str" "a string" } }
{ $description "Converts a string in base64 encoding back into its binary representation." }
{ $examples
    { $unchecked-example "\"VGhlIG1vbm9yYWlsIGlzIGEgZnJlZSBzZXJ2aWNlLg==\" base64> ." "\"The monorail is a free service.\"" }
}
{ $notes "This word will throw if the input string contains characters other than those allowed in base64 encodings." }
{ $see-also >base64 } ;

