! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.encodings strings ;
IN: io.encodings.utf16

ARTICLE: "io.encodings.utf16" "UTF-16 encoding"
"The UTF-16 encoding is a variable-width encoding. Unicode code points are encoded as 2 or 4 byte sequences. There are three encoding descriptor classes for working with UTF-16, depending on endianness or the presence of a BOM:"
{ $subsections
    utf16
    utf16le
    utf16be
} ;

ABOUT: "io.encodings.utf16"

HELP: utf16le
{ $class-description "The encoding descriptor for UTF-16LE, that is, UTF-16 in little endian, without a byte order mark. Streams can be made which read or write wth this encoding." }
{ $see-also "encodings-introduction" } ;

HELP: utf16be
{ $class-description "The encoding descriptor for UTF-16BE, that is, UTF-16 in big endian, without a byte order mark. Streams can be made which read or write wth this encoding." }
{ $see-also "encodings-introduction" } ;

HELP: utf16
{ $class-description "The encoding descriptor for UTF-16, that is, UTF-16 with a byte order mark. This is the most useful for general input and output in UTF-16. Streams can be made which read or write wth this encoding." }
{ $see-also "encodings-introduction" } ;

{ utf16 utf16le utf16be } related-words
