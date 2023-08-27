! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: assocs hashtables help.syntax help.markup io strings ;

IN: ini-file

HELP: read-ini
{ $values { "assoc" assoc } }
{ $description
    "Reads and parses an INI configuration from the " { $link input-stream }
    " and returns the result as a nested " { $link hashtable }
    "."
} ;

HELP: write-ini
{ $values { "assoc" assoc } }
{ $description
    "Writes a configuration to the " { $link output-stream }
    " in the INI format."
} ;

HELP: string>ini
{ $values { "str" string } { "assoc" assoc } }
{ $description
    "Parses the specified " { $link string } " as an INI configuration"
    " and returns the result as a nested " { $link hashtable }
    "."
} ;

HELP: ini>string
{ $values { "assoc" assoc } { "str" string } }
{ $description
    "Encodes the specified " { $link hashtable } " as an INI configuration."
} ;
