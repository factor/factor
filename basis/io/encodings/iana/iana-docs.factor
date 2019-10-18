USING: help.syntax help.markup strings ;
IN: io.encodings.iana

ABOUT: "io.encodings.iana"

ARTICLE: "io.encodings.iana" "IANA-registered encoding names"
"The " { $vocab-link "io.encodings.iana" } " vocabulary provides words for accessing the names of encodings and the encoding descriptors corresponding to names." $nl
"Most text encodings in common use have been registered with IANA. There is a standard set of names for each encoding. Simple conversion functions:"
{ $subsections
    name>encoding
    encoding>name
}
"To let a new encoding be used with the above words, use the following:"
{ $subsections register-encoding } ;

HELP: name>encoding
{ $values { "name" "an encoding name" } { "encoding" "an encoding descriptor" } }
{ $description "Given an IANA-registered encoding name, find the encoding descriptor that represents it, or " { $snippet "f" } " if it is not found (either not implemented in Factor or not registered)." } ;

HELP: encoding>name
{ $values { "encoding" "an encoding descriptor" } { "name" "an encoding name" } }
{ $description "Given an encoding descriptor, return the preferred IANA name. If no name is found, returns " { $snippet "f" } "." } ;

{ name>encoding encoding>name } related-words

HELP: register-encoding
{ $values { "descriptor" "an encoding descriptor" } { "name" string } }
{ $description "Registers an encoding descriptor with the given name, available for lookup through " { $link name>encoding } " and " { $link encoding>name } ". IANA-registered aliases are automatically included. The name given must be the first name in the " { $snippet "resources:basis/io/encodings/iana/character-sets" } " file." } ;
