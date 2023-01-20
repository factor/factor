! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: io.encodings.utf32

ARTICLE: "io.encodings.utf32" "UTF-32 encoding"
"The UTF-32 encoding is a fixed-width encoding. Unicode code points are encoded as 4 byte sequences. There are three encoding descriptor classes for working with UTF-32, depending on endianness or the presence of a BOM:"
{ $subsections
    utf32
    utf32le
    utf32be
} ;

ABOUT: "io.encodings.utf32"

HELP: utf32le
{ $class-description "The encoding descriptor for UTF-32LE, that is, UTF-32 in little endian, without a byte order mark. Streams can be made which read or write wth this encoding." }
{ $see-also "encodings-introduction" } ;

HELP: utf32be
{ $class-description "The encoding descriptor for UTF-32BE, that is, UTF-32 in big endian, without a byte order mark. Streams can be made which read or write wth this encoding." }
{ $see-also "encodings-introduction" } ;

HELP: utf32
{ $class-description "The encoding descriptor for UTF-32, that is, UTF-32 with a byte order mark. This is the most useful for general input and output in UTF-32. Streams can be made which read or write wth this encoding." }
{ $see-also "encodings-introduction" } ;

{ utf32 utf32le utf32be } related-words
