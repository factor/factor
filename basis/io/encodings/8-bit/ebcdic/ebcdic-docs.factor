! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: io.encodings.8-bit.ebcdic

HELP: ebcdic
{ $var-description "EBCDIC is an 8-bit legacy encoding designed for IBM mainframes like System/360 in the 1960s. It has since fallen into disuse. It contains large unallocated regions, and the version included here (code page 37) contains auxiliary characters in this region for English- and Portugese-speaking countries." } 
{ $see-also "encodings-introduction" } ;

ARTICLE: "io.encodings.8-bit.ebcdic" "EBCDIC encoding"
"The " { $vocab-link "io.encodings.8-bit.ebcdic" } " vocabulary provides the " { $link ebcdic } " encoding." ;

ABOUT: "io.encodings.8-bit.ebcdic"
