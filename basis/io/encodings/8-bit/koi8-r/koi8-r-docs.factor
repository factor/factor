! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: io.encodings.8-bit.koi8-r

HELP: koi8-r
{ $var-description "KOI8-R is an 8-bit superset of ASCII which encodes the Cyrillic alphabet, as used in Russian and Bulgarian. Characters are in such an order that, if the eight bit is stripped, text is still interpretable as ASCII. Block-building characters also exist." }
{ $see-also "encodings-introduction" } ;

ARTICLE: "io.encodings.8-bit.koi8-r" "KOI8-R encoding"
"The " { $vocab-link "io.encodings.8-bit.koi8-r" } " vocabulary provides the " { $link koi8-r } " encoding." ;

ABOUT: "io.encodings.8-bit.koi8-r"
