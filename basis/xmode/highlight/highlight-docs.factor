! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax sequences strings xmode.catalog
xmode.highlight xmode.tokens ;

IN: xmode.highlight

HELP: highlight-tokens
{ $values { "tokens" sequence } }
{ $description
    "Highlight a sequence of " { $link token } " objects."
} ;

HELP: highlight-lines
{ $values { "lines" sequence } { "mode" string } }
{ $description
    "Highlight lines of code, according to the specified " { $link mode }
    "."
} ;

HELP: highlight.
{ $values { "path" string } }
{ $description
    "Highlight and print code from the specified file (represented by "
    { $snippet "path" } ").  The mode is determined using the file extension."
} ;
