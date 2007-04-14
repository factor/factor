USING: help.markup help.syntax ;
IN: io.encodings.ascii

HELP: ascii
{ $class-description "This is the encoding descriptor which denotes an ASCII encoding. By default, if there's a non-ASCII character in an input stream, it will be replaced with a replacement character (U+FFFD), and if a non-ASCII character is used in output, an exception is thrown." }
{ $see-also "encodings-introduction" } ;

ABOUT: ascii
