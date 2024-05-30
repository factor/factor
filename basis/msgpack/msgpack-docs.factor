USING: byte-arrays help.markup help.syntax io kernel sequences strings ;

IN: msgpack

HELP: read-msgpack
{ $values { "obj" object } }
{ $description "Decodes an object that was serialized in the MessagePack format, reading from an " { $link input-stream } "." } ;

HELP: ?read-msgpack
{ $values { "obj/f" object } { "?" boolean } }
{ $description "Reads the next byte from an " { $link input-stream } " and if not EOF, decodes an object that was serialized in the MessagePack format." } ;

HELP: read-msgpacks
{ $values { "objs" sequence } }
{ $description "Reads an unknown number of objects from the " { $link input-stream } " that were serialized in the MessagePack format." } ;

HELP: write-msgpack
{ $values { "obj" object } }
{ $description "Encodes an object into the MessagePack format, writing to an " { $link output-stream } "." } ;

HELP: msgpack>
{ $values { "seq" sequence } { "obj" object } }
{ $description "Decodes an object from the MessagePack format, represented as a " { $link byte-array } " or " { $link string } "." } ;

HELP: >msgpack
{ $values { "obj" object } { "bytes" byte-array } }
{ $description "Encodes an object into the MessagePack format." } ;

ARTICLE: "msgpack" "MessagePack"
"Decoding support for the MessagePack protocol:"
{ $subsections
    read-msgpack
    ?read-msgpack
    read-msgpacks
    msgpack>
}
"Encoding support for the MessagePack protocol:"
{ $subsections
    write-msgpack
    >msgpack
} ;

ABOUT: "msgpack"
