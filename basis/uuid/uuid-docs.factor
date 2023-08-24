USING: help.markup help.syntax strings ;

IN: uuid

HELP: uuid1
{ $values { "string" "a UUID string" } }
{ $description
    "Generates a UUID (version 1) from the host ID, sequence number, "
    "and current time."
} ;

HELP: uuid3
{ $values { "namespace" string } { "name" string } { "string" "a UUID string" } }
{ $description
    "Generates a UUID (version 3) from the MD5 hash of a namespace "
    "UUID and a name."
} ;

HELP: uuid4
{ $values { "string" "a UUID string" } }
{ $description
    "Generates a UUID (version 4) from random bits."
} ;

HELP: uuid5
{ $values { "namespace" string } { "name" string } { "string" "a UUID string" } }
{ $description
    "Generates a UUID (version 5) from the SHA-1 hash of a namespace "
    "UUID and a name."
} ;


ARTICLE: "uuid" "UUID (Universally Unique Identifier)"
"The " { $vocab-link "uuid" } " vocabulary is used to generate UUIDs. "
"The below words can be used to generate version 1, 3, 4, and 5 UUIDs as specified in RFC 4122."
$nl
"If all you want is a unique ID, you should probably call " { $link uuid1 } " or " { $link uuid4 } "."
{ $subsections
    uuid1
    uuid3
    uuid4
    uuid5
}
;

ABOUT: "uuid"
