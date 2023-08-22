! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax sequences strings words
xmode.catalog xmode.highlight xmode.tokens ;

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
{ $values { "obj" string } }
{ $description
    "Highlight and print code from the specified " { $link word } " or path (with a mode determined using the file extension)."
} ;
