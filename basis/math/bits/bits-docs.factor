! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup kernel math sequences ;
IN: math.bits

ABOUT: "math.bits"

ARTICLE: "math.bits" "Integer virtual sequences"
"The " { $vocab-link "math.bits" } " vocabulary implements words that represent a positive integer as a virtual sequence of bits in order of ascending significance, e.g. " { $snippet "{ f f f t }" } " is " { $snippet "8" } "."
{ $subsections
    bits
    <bits>
    make-bits
    bits>number
}
"If you need binary digits instead of " { $link boolean } ", then you can use these:"
{ $subsections
    binary-bits
    <binary-bits>
    make-binary-bits
} ;

HELP: bits
{ $class-description "Tuple representing a number as a virtual sequence of booleans. The first bit is the least significant bit. Constructors are " { $link <bits> } " or " { $link make-bits } "." } ;

HELP: <bits>
{ $values { "number" integer } { "length" integer } { "bits" bits } }
{ $description "Constructor for a " { $link bits } " tuple." } ;

HELP: make-bits
{ $values { "number" integer } { "bits" bits } }
{ $description "Creates a sequence of " { $link bits } " in ascending significance. Throws an error on negative numbers." }
{ $examples
    { $example "USING: math.bits prettyprint arrays ;" "0b1101 make-bits >array ." "{ t f t t }" }
    { $example "USING: math.bits prettyprint arrays ;" "64 make-bits >array ." "{ f f f f f f t }" }
} ;
{ <bits> make-bits } related-words

HELP: bits>number
{ $values { "seq" sequence } { "number" integer } }
{ $description "Converts a sequence of booleans in ascending significance into a number." } ;
{ make-bits bits>number } related-words

HELP: binary-bits
{ $class-description "Tuple representing a number as a virtual sequence of binary digits. The first bit is the least significant bit. Constructors are " { $link <binary-bits> } " or " { $link make-binary-bits } "." } ;

HELP: <binary-bits>
{ $values { "number" integer } { "length" integer } { "binary-bits" binary-bits } }
{ $description "Constructor for a " { $link binary-bits } " tuple." } ;

HELP: make-binary-bits
{ $values { "number" integer } { "binary-bits" binary-bits } }
{ $description "Creates a sequence of " { $link binary-bits } " in ascending significance. Throws an error on negative numbers." }
{ $examples
    { $example "USING: math.bits prettyprint arrays ;" "0b1101 make-binary-bits >array ." "{ 1 0 1 1 }" }
    { $example "USING: math.bits prettyprint arrays ;" "64 make-binary-bits >array ." "{ 0 0 0 0 0 0 1 }" }
} ;
{ <binary-bits> make-binary-bits } related-words
