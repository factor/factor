! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays continuations help.markup help.syntax io
kernel words ;
IN: serialize

HELP: serialize
{ $values { "obj" "object to serialize" } }
{ $description "Serializes the object to " { $link output-stream } "." } ;

HELP: deserialize
{ $values { "obj" "deserialized object" } }
{ $description "Deserializes an object by reading from " { $link input-stream } "." } ;

HELP: object>bytes
{ $values { "obj" "object to serialize" } { "bytes" byte-array }
}
{ $description "Serializes the object to a byte array." } ;

HELP: bytes>object
{ $values { "bytes" byte-array } { "obj" "deserialized object" }
}
{ $description "Deserializes an object from a byte array." } ;

HELP: deep-clone
{ $values { "obj" object } { "obj'" object } }
{ $description "Deep clones an object by serializing and then deserializing, with the same limitations those words have. For example, certain types like " { $link word } " deep clone as themselves, other types like " { $link continuation } " are not supported, and some objects like " { $link f } " come back as themselves." } ;

ARTICLE: "serialize" "Binary object serialization"
"The " { $vocab-link "serialize" } " vocabulary implements binary serialization for all Factor data types except for continuations. Unlike the prettyprinter, shared structure and circularity is preserved."
$nl
"Storing objects on streams:"
{ $subsections
    serialize
    deserialize
}
"Storing objects as byte arrays:"
{ $subsections
    object>bytes
    bytes>object
} ;

ABOUT: "serialize"
