! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup sequences ;
IN: io.crlf

HELP: crlf
{ $values }
{ $description "Prints a carriage return and line feed to the current output stream, used to indicate a newline for certain network protocols." } ;

HELP: read-crlf
{ $values { "seq" sequence } }
{ $description "Reads until the next CRLF (carriage return followed by line feed) from the current input stream, throwing an error if CR is present without immediately being followed by LF." } ;

HELP: read-?crlf
{ $values { "seq" sequence } }
{ $description "Reads until the next LF (line feed) or CRLF (carriage return followed by line feed) from the current input stream, throwing an error if CR is present without immediately being followed by LF." } ;

{ crlf>lf lf>crlf } related-words
