USING: help.syntax help.markup ;
IN: io.encodings.iana

HELP: name>encoding
{ $values { "name" "an encoding name" } { "encoding" "an encoding descriptor" } }
{ "Given an IANA-registered encoding name, find the encoding descriptor that represents it, or " { $code f } " if it is not found (either not implemented in Factor or not registered)." } ;

HELP: encoding>name
{ $values { "encoding" "an encoding descriptor" } { "name" "an encoding name" } }
{ "Given an encoding descriptor, return the preferred IANA name." } ;

{ name>encoding encoding>name } related-words
