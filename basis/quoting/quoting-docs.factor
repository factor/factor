! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings ;
IN: quoting

HELP: quote?
{ $values
     { "ch" "a character" }
     { "?" "a boolean" }
}
{ $description "Returns true if the character is a single or double quote." } ;

HELP: quoted?
{ $values
     { "str" string }
     { "?" "a boolean" }
}
{ $description "Returns true if a string is surrounded by matching single or double quotes as the first and last characters." } ;

HELP: unquote
{ $values
     { "str" string }
     { "newstr" string }
}
{ $description "Removes a pair of matching single or double quotes from a string." } ;

ARTICLE: "quoting" "Quotation marks"
"The " { $vocab-link "quoting" } " vocabulary is for removing quotes from a string." $nl
"Removing quotes:"
{ $subsection unquote } ;

ABOUT: "quoting"
