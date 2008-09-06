USING: help.markup help.syntax math ;
IN: math.bitwise

ARTICLE: "math-bitfields" "Constructing bit fields"
"Some applications, such as binary communication protocols and assemblers, need to construct integers from elaborate bit field specifications. Hand-coding this using " { $link shift } " and " { $link bitor } " results in repetitive code. A higher-level facility exists to factor out this repetition:"
{ $subsection bitfield } ;

ABOUT: "math-bitfields"

HELP: bitfield
{ $values { "values..." "a series of objects" } { "bitspec" "an array" } { "n" integer } }
{ $description "Constructs an integer from a series of values on the stack together with a bit field specifier, which is an array whose elements have one of the following shapes:"
    { $list
        { { $snippet "{ constant shift }" } " - the resulting bit field is bitwise or'd with " { $snippet "constant" } " shifted to the right by " { $snippet "shift" } " bits" }
        { { $snippet "{ word shift }" } " - the resulting bit field is bitwise or'd with " { $snippet "word" } " applied to the top of the stack; the result is shifted to the right by " { $snippet "shift" } " bits" }
        { { $snippet "shift" } " - the resulting bit field is bitwise or'd with the top of the stack; the result is shifted to the right by " { $snippet "shift" } " bits" }
    }
"The bit field specifier is processed left to right, so stack values should be supplied in reverse order." }
{ $examples
    "Consider the following specification:"
    { $list
        { "bits 0-10 are set to the value of " { $snippet "x" } }
        { "bits 11-14 are set to the value of " { $snippet "y" } }
        { "bit 15 is always on" }
        { "bits 16-20 are set to the value of " { $snippet "fooify" } " applied to " { $snippet "z" } }
    }
    "Such a bit field construction can be specified with a word like the following:"
    { $code
        ": baz-bitfield ( x y z -- n )"
        "    {"
        "        { fooify 16 }"
        "        { 1 15 }"
        "        11"
        "        0"
        "    } ;"
    }
} ;

HELP: bits 
{ $values { "m" integer } { "n" integer } { "m'" integer } }
{ $description "Keep only n bits from the integer m." }
{ $example "USING: math.bitwise prettyprint ;" "HEX: 123abcdef 16 bits .h" "cdef" } ;

HELP: bitroll
{ $values { "x" "an integer (input)" } { "s" "an integer (shift)" } { "w" "an integer (wrap)" } { "y" integer } }
{ $description "Roll n by s bits to the left, wrapping around after w bits." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;" "1 -1 32 bitroll .b" "10000000000000000000000000000000" }
    { $example "USING: math.bitwise prettyprint ;" "HEX: ffff0000 8 32 bitroll .h" "ff0000ff" }
} ;
