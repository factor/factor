USING: byte-arrays help.markup help.syntax math
math.parser.private prettyprint make sequences
strings ;

IN: math.parser

ARTICLE: "number-strings" "Converting between numbers and strings"
"These words only convert between real numbers and strings. Complex numbers are constructed by the parser (" { $link "parser" } ") and printed by the prettyprinter (" { $link "prettyprint" } ")."
$nl
"Integers can be converted to and from arbitrary bases. Floating point numbers can only be converted to and from base 10 and 16."
$nl
"Converting numbers to strings:"
{ $subsections
    number>string
    >bin
    >oct
    >hex
    >base
}
"Converting strings to numbers:"
{ $subsections
    string>number
    bin>
    oct>
    hex>
    base>
}
"You can also input literal numbers in a different base (" { $link "syntax-integers" } ")."
{ $see-also "prettyprint-numbers" } ;

ABOUT: "number-strings"

HELP: >digit
{ $values { "n" "an integer between 0 and 15" } { "ch" "a character" } }
{ $description "Outputs a character representation of a digit." }
{ $notes "This is one of the factors of " { $link number>string } "." } ;

HELP: digit>
{ $values { "ch" "a character" } { "n" integer } }
{ $description "Converts a character representation of a digit to an integer." }
{ $notes "This is one of the factors of " { $link string>number } "." } ;

HELP: base>
{ $values { "str" string } { "radix" "an integer between 2 and 16" } { "n/f" { $maybe real } } }
{ $description "Creates a real number from a string representation with the given radix. The radix for floating point literals can be either base 10 or base 16."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ >base base> } related-words

HELP: string>number
{ $values { "str" string } { "n/f" { $maybe real } } }
{ $description "Creates a real number from a string representation of a number in base 10."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ string>number number>string } related-words

HELP: bin>
{ $values { "str" string } { "n/f" { $maybe real } } }
{ $description "Creates a real number from a string representation of a number in base 2."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ >bin bin> .b } related-words

HELP: oct>
{ $values { "str" string } { "n/f" { $maybe real } } }
{ $description "Creates a real number from a string representation of a number in base 8."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ >oct oct> .o } related-words

HELP: hex>
{ $values { "str" string } { "n/f" { $maybe real } } }
{ $description "Creates a real number from a string representation of a number in base 16."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ >hex hex> .h } related-words

HELP: >base
{ $values { "n" real } { "radix" "an integer between 2 and 16" } { "str" string } }
{ $description "Converts a real number into a string representation using the given radix. If the number is a " { $link float } ", the radix can be either base 10 or base 16." } ;

HELP: >bin
{ $values { "n" real } { "str" string } }
{ $description "Outputs a string representation of a number using base 2." } ;

HELP: >oct
{ $values { "n" real } { "str" string } }
{ $description "Outputs a string representation of a number using base 8." } ;

HELP: >hex
{ $values { "n" real } { "str" string } }
{ $description "Outputs a string representation of a number using base 16." }
{ $examples
    { $example
        "USING: math.parser prettyprint ;"
        "3735928559 >hex ."
        "\"deadbeef\""
    }
    { $example
        "USING: math.parser prettyprint ;"
        "-15.5 >hex ."
        "\"-1.fp3\""
    }
} ;

HELP: number>string
{ $values { "n" real } { "str" string } }
{ $description "Converts a real number to a string." }
{ $notes "Printing complex numbers requires the more general prettyprinter facility (see " { $link "prettyprint" } ")." } ;

HELP: #
{ $values { "n" real } }
{ $description "Appends the string representation of a real number to the end of the sequence being constructed by " { $link make } "." } ;

HELP: bytes>hex-string
{ $values { "bytes" sequence } { "hex-string" string } }
{ $description "Converts a sequence of bytes (integers in the range [0,255]) to a string of hex numbers in the range [00,ff]." }
{ $examples
    { $example "USING: math.parser prettyprint ;" "B{ 1 2 3 4 } bytes>hex-string ." "\"01020304\"" }
}
{ $notes "Numbers are zero-padded on the left." } ;

HELP: hex-string>bytes
{ $values { "hex-string" sequence } { "bytes" byte-array } }
{ $description "Converts a sequence of hex numbers in the range [00,ff] to a sequence of bytes (integers in the range [0,255])." }
{ $examples
    { $example "USING: math.parser prettyprint ;" "\"cafebabe\" hex-string>bytes ." "B{ 202 254 186 190 }" }
} ;

{ bytes>hex-string hex-string>bytes } related-words
