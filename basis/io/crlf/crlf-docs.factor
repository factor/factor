! Copyright (C) 2009, 2023 Daniel Ehrenberg, Alexander Ilin
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup io quotations sequences ;
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

HELP: use-crlf-stream
{ $description "Substitutes the current " { $link output-stream } " with a wrapper that outputs CR followed by LF for every " { $link stream-nl } " call (words like " { $link print } " and " { $link nl } " use that internally)." } ;

HELP: with-crlf-stream
{ $values { "quot" quotation } }
{ $description "Substitutes the current " { $link output-stream } " with a wrapper that outputs CR followed by LF for every " { $link stream-nl } " call (words like " { $link print } " and " { $link nl } " use that internally)." } ;

{ crlf>lf lf>crlf } related-words
