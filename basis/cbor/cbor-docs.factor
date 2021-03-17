USING: byte-arrays help.markup help.syntax io kernel sequences strings ;

IN: cbor

HELP: read-cbor
{ $values { "obj" object } }
{ $description "Decodes an object that was serialized in the CBOR format, reading from an " { $link input-stream } "." } ;

HELP: write-cbor
{ $values { "obj" object } }
{ $description "Encodes an object into the CBOR format, writing to an " { $link output-stream } "." } ;

HELP: cbor>
{ $values { "seq" sequence } { "obj" object } }
{ $description "Decodes an object from the CBOR format, represented as a " { $link byte-array } " or " { $link string } "." } ;

HELP: >cbor
{ $values { "obj" object } { "bytes" byte-array } }
{ $description "Encodes an object into the CBOR format." } ;

ARTICLE: "cbor" "Concise Binary Object Representation (CBOR)"
"The Concise Binary Object Representation (CBOR) is defined in RFC 7049."
$nl
"Decoding support for the CBOR protocol:"
{ $subsections
    read-cbor
    cbor>
}
"Encoding support for the CBOR protocol:"
{ $subsections
    write-cbor
    >cbor
} ;

ABOUT: "cbor"
