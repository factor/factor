! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup math ;
IN: math.bits

ABOUT: "math.bits"

ARTICLE: "math.bits" "Number bits virtual sequence"
{ $subsection bits }
{ $subsection <bits> }
{ $subsection make-bits } ;

HELP: bits
{ $class-description "Virtual sequence class of bits of a number. The first bit is the least significant bit. This can be constructed with " { $link <bits> } " or " { $link make-bits } "." } ;

HELP: <bits>
{ $values { "number" integer } { "length" integer } { "bits" bits } }
{ $description "Creates a virtual sequence of bits of a number in little endian order, with the given length." } ;

HELP: make-bits
{ $values { "number" integer } { "bits" bits } }
{ $description "Creates a " { $link bits } " object out of the given number, using its log base 2 as the length. This implies that the last element, corresponding to the most significant bit, will be 1." }
{ $examples
    { $example "USING: math.bits prettyprint arrays ;" "BIN: 1101 make-bits >array ." "{ t f t t }" }
    { $example "USING: math.bits prettyprint arrays ;" "-3 make-bits >array ." "{ t f }" }
} ;
