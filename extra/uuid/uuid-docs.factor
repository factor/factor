
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


