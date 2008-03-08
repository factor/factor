! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup ;
IN: serialize

HELP: serialize
{ $values { "obj" "object to serialize" } 
}
{ $description "Serializes the object to the current output stream. Object references within the structure being serialized are maintained." } 
{ $examples 
    { $example "USING: serialize io.streams.string ;" "binary [ { 1 2 } serialize ] with-byte-writer\n\nbinary [ deserialize ] with-byte-reader ." "{ 1 2 }" }
}
{ $see-also deserialize } ;

HELP: deserialize
{ $values { "obj" "deserialized object" } 
}
{ $description "Deserializes an object by reading from the current input stream. Object references within the structure that was originally serialized are maintained." } 
{ $examples 
    { $example "USING: serialize io.streams.string ;" "binary [ { 1 2 } serialize ] with-byte-writer\n\nbinary [ deserialize ] with-byte-reader ." "{ 1 2 }" }
}
{ $see-also serialize } ;
