USING: help.markup help.syntax math math.parser.private prettyprint
namespaces make strings ;
IN: math.parser

ARTICLE: "number-strings" "Converting between numbers and strings"
"These words only convert between real numbers and strings. Complex numbers are constructed by the parser (" { $link "parser" } ") and printed by the prettyprinter (" { $link "prettyprint" } ")."
$nl
"Note that only integers can be converted to and from strings using a representation other than base 10. Calling a word such as " { $link >oct } " on a float will give a result in base 10."
$nl
"Converting numbers to strings:"
{ $subsection number>string }
{ $subsection >bin }
{ $subsection >oct }
{ $subsection >hex }
{ $subsection >base }
"Converting strings to numbers:"
{ $subsection string>number }
{ $subsection bin> }
{ $subsection oct> }
{ $subsection hex> }
{ $subsection base> }
"You can also input literal numbers in a different base (" { $link "syntax-integers" } ")."
{ $see-also "prettyprint-numbers" } ;

ABOUT: "number-strings"

HELP: digits>integer
{ $values { "seq" "a sequence of integers" } { "radix" "an integer between 2 and 36" } { "n/f" { $maybe integer } } }
{ $description "Converts a sequence of digits (with most significant digit first) into an integer." }
{ $notes "This is one of the factors of " { $link string>number } "." } ;

HELP: >digit
{ $values { "n" "an integer between 0 and 35" } { "ch" "a character" } }
{ $description "Outputs a character representation of a digit." }
{ $notes "This is one of the factors of " { $link number>string } "." } ;

HELP: digit>
{ $values { "ch" "a character" } { "n" integer } }
{ $description "Converts a character representation of a digit to an integer." }
{ $notes "This is one of the factors of " { $link string>number } "." } ;

HELP: base>
{ $values { "str" string } { "radix" "an integer between 2 and 36" } { "n/f" "a real number or " { $link f } } }
{ $description "Creates a real number from a string representation with the given radix. The radix is ignored for floating point literals; they are always taken to be in base 10."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ >base base> } related-words

HELP: string>number
{ $values { "str" string } { "n/f" "a real number or " { $link f } } }
{ $description "Creates a real number from a string representation of a number in base 10."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ string>number number>string } related-words

HELP: bin>
{ $values { "str" string } { "n/f" "a real number or " { $link f } } }
{ $description "Creates a real number from a string representation of a number in base 2."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ bin> POSTPONE: BIN: bin> .b } related-words

HELP: oct>
{ $values { "str" string } { "n/f" "a real number or " { $link f } } }
{ $description "Creates a real number from a string representation of a number in base 8."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ oct> POSTPONE: OCT: oct> .o } related-words

HELP: hex>
{ $values { "str" string } { "n/f" "a real number or " { $link f } } }
{ $description "Creates a real number from a string representation of a number in base 16."
$nl
"Outputs " { $link f } " if the string does not represent a number." } ;

{ hex> POSTPONE: HEX: hex> .h } related-words

HELP: >base
{ $values { "n" real } { "radix" "an integer between 2 and 36" } { "str" string } }
{ $description "Converts a real number into a string representation using the given radix. If the number is a float, the radix is ignored and the output is always in base 10." } ;

HELP: >bin
{ $values { "n" real } { "str" string } }
{ $description "Outputs a string representation of a number using base 2." } ;

HELP: >oct
{ $values { "n" real } { "str" string } }
{ $description "Outputs a string representation of a number using base 8." } ;

HELP: >hex
{ $values { "n" real } { "str" string } }
{ $description "Outputs a string representation of a number using base 16." } ;

HELP: string>float ( str -- n/f )
{ $values { "str" string } { "n/f" "a real number or " { $link f } } }
{ $description "Primitive for creating a float from a string representation." }
{ $notes "The " { $link string>number } " word is more general."
$nl
"Outputs " { $link f } " if the string does not represent a float." } ;

HELP: float>string
{ $values { "n" real } { "str" string } }
{ $description "Primitive for getting a string representation of a float." }
{ $notes "The " { $link number>string } " word is more general." } ;

HELP: number>string
{ $values { "n" real } { "str" string } }
{ $description "Converts a real number to a string." }
{ $notes "Printing complex numbers requires the more general prettyprinter facility (see " { $link "prettyprint" } ")." } ;

HELP: #
{ $values { "n" real } }
{ $description "Appends the string representation of a real number to the end of the sequence being constructed by " { $link make } "." } ;
