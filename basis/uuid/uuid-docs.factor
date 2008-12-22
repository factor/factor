
USING: help.syntax help.markup kernel prettyprint sequences strings ;

IN: uuid

HELP: uuid1
{ $description 
    "Generates a UUID (version 1) from the host ID, sequence number, "
    "and current time."
} ;

HELP: uuid3
{ $description 
    "Generates a UUID (version 3) from the MD5 hash of a namespace "
    "UUID and a name."
} ;

HELP: uuid4
{ $description 
    "Generates a UUID (version 4) from random bits." 
} ;

HELP: uuid5
{ $description 
    "Generates a UUID (version 5) from the SHA-1 hash of a namespace " 
    "UUID and a name."
} ;


ARTICLE: "uuid" "UUID (Universally Unique Identifier)"
"The " { $vocab-link "uuid" } " vocabulary is used to generate UUID's. "
"The words uuid1, uuid3, uuid4, uuid5 can be used to generate version "
"1, 3, 4, and 5 UUIDs as specified in RFC 4122.\n"
"\n" 
"If all you want is a unique ID, you should probably call uuid1 or uuid4."
"\n"
{ $subsection uuid1 }
{ $subsection uuid3 }
{ $subsection uuid4 }
{ $subsection uuid5 }
;

ABOUT: "uuid"


