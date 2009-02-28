! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup ;
IN: io.encodings.blackhole

ARTICLE: "io.encodings.blackhole" "yet another /dev/null in Factor encodings"
"The " { $vocab-link "io.encodings.blackhole" } " vocab is yet another port of Un*x /dev/null special device file."
{ $subsection blackhole }
{
    $see-also
    "encodings-introduction"
    "encode"  "decode"
    "file-reader"  "file-writer"
    "ascii" "binary"
}
;

ABOUT: "io.encodings.blackhole"

HELP: blackhole
{ $class-description "blackhole encoding class specified to input/output encoding, it consume everything and produce nothing." }
;