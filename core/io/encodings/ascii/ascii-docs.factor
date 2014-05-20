USING: help.markup help.syntax ;
IN: io.encodings.ascii

HELP: ascii
{ $class-description "ASCII encoding descriptor." } ;

ARTICLE: "io.encodings.ascii" "ASCII encoding"
"By default, if there's a non-ASCII character in an input stream, it will be replaced with a replacement character (U+FFFD), and if a non-ASCII character is used in output, an exception is thrown."
{ $subsections ascii } ;

ABOUT: "io.encodings.ascii"
