! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup math sequences ;
IN: math.bits

ABOUT: "math.bits"

ARTICLE: "math.bits" "Number bits virtual sequence"
"The " { $vocab-link "math.bits" } " vocabulary implements a virtual sequence which presents an integer as a sequence of bits, with the first element of the sequence being the least significant bit of the integer."
{ $subsections
    bits
    <bits>
    make-bits
} ;

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

HELP: unbits
{ $values { "seq" sequence } { "number" integer } }
{ $description "Turns a sequence of booleans, of the same format made by the " { $link bits } " class, and calculates the number that it represents as little-endian." } ;
