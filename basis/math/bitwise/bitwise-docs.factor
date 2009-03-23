! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax math sequences ;
IN: math.bitwise

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
{ $values { "x" integer } { "s" "a shift integer" } { "w" "a wrap integer" } { "y" integer }
}
{ $description "Roll n by s bits to the left, wrapping around after w bits." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;" "1 -1 32 bitroll .b" "10000000000000000000000000000000" }
    { $example "USING: math.bitwise prettyprint ;" "HEX: ffff0000 8 32 bitroll .h" "ff0000ff" }
} ;

HELP: bit-clear?
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "Returns " { $link t } " if the nth bit is set to zero." }
{ $examples 
    { $example "USING: math.bitwise prettyprint ;"
               "HEX: ff 8 bit-clear? ."
               "t"
    }
    { $example "" "USING: math.bitwise prettyprint ;"
               "HEX: ff 7 bit-clear? ."
               "f"
    }
} ;

{ bit? bit-clear? set-bit clear-bit } related-words

HELP: bit-count
{ $values
     { "x" integer }
     { "n" integer }
}
{ $description "Returns the number of set bits as an integer." }
{ $examples 
    { $example "USING: math.bitwise prettyprint ;"
               "HEX: f0 bit-count ."
               "4"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "-7 bit-count ."
               "2"
    }
} ;

HELP: bitroll-32
{ $values
     { "n" integer } { "s" integer }
     { "n'" integer }
}     
{ $description "Rolls the number " { $snippet "n" } " by " { $snippet "s" } " bits to the left, wrapping around after 32 bits." }
{ $examples 
    { $example "USING: math.bitwise prettyprint ;"
               "HEX: 1 10 bitroll-32 .h"
               "400"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "HEX: 1 -10 bitroll-32 .h"
               "400000"
    }
} ;

HELP: bitroll-64
{ $values
     { "n" integer } { "s" "a shift integer" }
     { "n'" integer }
}
{ $description "Rolls the number " { $snippet "n" } " by " { $snippet "s" } " bits to the left, wrapping around after 64 bits." }
{ $examples 
    { $example "USING: math.bitwise prettyprint ;"
               "HEX: 1 10 bitroll-64 .h"
               "400"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "HEX: 1 -10 bitroll-64 .h"
               "40000000000000"
    }
} ;

{ bitroll bitroll-32 bitroll-64 } related-words

HELP: clear-bit
{ $values
     { "x" integer } { "n" integer }
     { "y" integer }
}
{ $description "Sets the nth bit of " { $snippet "x" } " to zero." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "HEX: ff 7 clear-bit .h"
        "7f"
    }
} ;

HELP: flags
{ $values
     { "values" sequence }
}
{ $description "Constructs a constant flag value from a sequence of integers or words that output integers. The resulting constant is computed at compile-time, which makes this word as efficient as using a literal integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "IN: scratchpad"
        "CONSTANT: x HEX: 1"
        "{ HEX: 20 x BIN: 100 } flags .h"
        "25"
    }
} ;

HELP: mask
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "After the operation, only the bits that were set in both the mask and the original number are set." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "BIN: 11111111 BIN: 101 mask .b"
        "101"
    }
} ;

HELP: mask-bit
{ $values
     { "m" integer } { "n" integer }
     { "m'" integer }
}
{ $description "Turns off all bits besides the nth bit." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "HEX: ff 2 mask-bit .b"
        "100"
    }
} ;

HELP: mask?
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "Returns true if all of the bits in the mask " { $snippet "n" } " are set in the integer input " { $snippet "x" } "." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "HEX: ff HEX: f mask? ."
        "t"
    }

    { $example "USING: math.bitwise kernel prettyprint ;"
        "HEX: f0 HEX: 1 mask? ."
        "f"
    }
} ;

HELP: on-bits
{ $values
     { "n" integer }
     { "m" integer }
}
{ $description "Returns an integer with " { $snippet "n" } " bits set." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "6 on-bits .h"
        "3f"
    }
    { $example "USING: math.bitwise kernel prettyprint ;"
        "64 on-bits .h"
        "ffffffffffffffff"
    }
} ;

HELP: toggle-bit
{ $values
     { "m" integer }
     { "n" integer }
     { "m'" integer }
}
{ $description "Toggles the nth bit of an integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0 3 toggle-bit .b"
        "1000"
    }
    { $example "USING: math.bitwise kernel prettyprint ;"
        "BIN: 1000 3 toggle-bit .b"
        "0"
    }
} ;

HELP: set-bit
{ $values
     { "x" integer } { "n" integer }
     { "y" integer }
}
{ $description "Sets the nth bit of " { $snippet "x" } "." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0 5 set-bit .h"
        "20"
    }
} ;

HELP: shift-mod
{ $values
     { "n" integer } { "s" integer } { "w" integer }
     { "n" integer }
}
{ $description "Calls " { $link shift } " on " { $snippet "n" } " and " { $snippet "s" } ", wrapping the result to " { $snippet "w" } " bits." } ;

HELP: unmask
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "Clears the bits in " { $snippet "x" } " if they are set in the mask " { $snippet "n" } "." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "HEX: ff  HEX: 0f unmask .h"
        "f0"
    }
} ;

HELP: unmask?
{ $values
     { "x" integer } { "n" integer }
     { "?" "a boolean" }
}
{ $description "Tests whether unmasking the bits in " { $snippet "x" } " would return an integer greater than zero." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "HEX: ff  HEX: 0f unmask? ."
        "t"
    }
} ;

HELP: w*
{ $values
     { "int" integer } { "int" integer }
     { "int" integer }
}
{ $description "Multiplies two integers and wraps the result to 32 bits." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "HEX: ffffffff HEX: 2 w* ."
        "4294967294"
    }
} ;

HELP: w+
{ $values
     { "int" integer } { "int" integer }
     { "int" integer }
}
{ $description "Adds two integers and wraps the result to 32 bits." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "HEX: ffffffff HEX: 2 w+ ."
        "1"
    }
} ;

HELP: w-
{ $values
     { "int" integer } { "int" integer }
     { "int" integer }
}
{ $description "Subtracts two integers and wraps the result to 32 bits." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "HEX: 0 HEX: ff w- ."
        "4294967041"
    }
} ;

HELP: wrap
{ $values
     { "m" integer } { "n" integer }
     { "m'" integer }
}
{ $description "Wraps an integer " { $snippet "m" } " by modding it by " { $snippet "n" } ". This word is uses bitwise arithmetic and does not actually call the modulus word, and as such can only mod by powers of two." }
{ $examples "Equivalent to modding by 8:"
    { $example 
        "USING: math.bitwise prettyprint ;"
        "HEX: ffff 8 wrap .h"
        "7"
    }
} ;

ARTICLE: "math-bitfields" "Constructing bit fields"
"Some applications, such as binary communication protocols and assemblers, need to construct integers from elaborate bit field specifications. Hand-coding this using " { $link shift } " and " { $link bitor } " results in repetitive code. A higher-level facility exists to factor out this repetition:"
{ $subsection bitfield } ;

ARTICLE: "math.bitwise" "Additional bitwise arithmetic"
"The " { $vocab-link "math.bitwise" } " vocabulary provides bitwise arithmetic words extending " { $link "bitwise-arithmetic" } ". They are useful for efficiency, low-level programming, and interfacing with C libraries."
$nl
"Setting and clearing bits:"
{ $subsection set-bit }
{ $subsection clear-bit }
"Testing if bits are set or clear:"
{ $subsection bit? }
{ $subsection bit-clear? }
"Operations with bitmasks:"
{ $subsection mask }
{ $subsection unmask }
{ $subsection mask? }
{ $subsection unmask? }
"Generating an integer with n set bits:"
{ $subsection on-bits }
"Counting the number of set bits:"
{ $subsection bit-count }
"More efficient modding by powers of two:"
{ $subsection wrap }
"Bit-rolling:"
{ $subsection bitroll }
{ $subsection bitroll-32 }
{ $subsection bitroll-64 }
"32-bit arithmetic:"
{ $subsection w+ }
{ $subsection w- }
{ $subsection w* }
"Bitfields:"
{ $subsection flags }
{ $subsection "math-bitfields" } ;

ABOUT: "math.bitwise"
