! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax math sequences kernel ;
IN: math.bitwise

HELP: bitfield
{ $values { "values..." "a series of objects on the stack" } { "bitspec" "an array" } { "n" integer } }
    { $description "Constructs an integer (bit field) from a series of values on the stack together with a bit field specifier, which is an array whose elements have one of the following shapes:"
    { $list
        { { $snippet "{ word shift }" } " - " { $snippet "word" } " is applied to the top of the stack and the result is shifted to the left by " { $snippet "shift" } " bits and bitor'd with the bit field" }
        { { $snippet "shift" } " - the top of the stack is shifted to the left by " { $snippet "shift" } " bits and bitor'd with the bit field" }
        { { $snippet "{ constant shift }" } " - " { $snippet "constant" } " is shifted to the left by " { $snippet "shift" } " bits and bitor'd with the bit field" }
    }
    "The last entry in the bit field specifier is processed in reverse, so stack values are supplied in reverse order, e.g. the leftmost stack value is the last bit field specifier."
}
{ $examples
    "Consider the following specification:"
    { $list
        { "bits 0-10 are set to the value of " { $snippet "x" } }
        { "bits 11-14 are set to the value of " { $snippet "y" } }
        { "bit 15 is always on" }
        { "bits 16-20 are set to the value of " { $snippet "fooify" } " applied to " { $snippet "z" } }
    }
    "Such a bit field construction can be specified with a word like the following:"
    { $example
        "USING: math math.bitwise prettyprint ;"
        "IN: math.bitwise.examples"
        ": fooify ( x -- y ) 0b1111 bitand ;"
        ": baz-bitfield ( x y z -- n )"
        "    {"
        "        { fooify 16 }"
        "        { 1 15 }"
        "        11"
        "        0"
        "    } bitfield ;"
        "3 2 1 baz-bitfield ."
        "102403"
    }
    "Square the 3 from the stack and shift 8, place the 1 from the stack at bit 5, and shift a constant 1 to bit 2:"
    { $example
        "USING: math math.bitwise prettyprint ;"
        "1 3"
        "    {"
        "        { sq 8 }"
        "        5"
        "        { 1 2 }"
        "    } bitfield .b"
        "0b100100100100"
    }
} ;

HELP: bitfield*
{ $values { "values..." "a series of objects on the stack" } { "bitspec" "an array" } { "n" integer } }
{ $description "Constructs an integer (bit field) from a series of values on the stack together with a bit field specifier, which is an array whose elements have one of the following shapes:"
    { $list
        { { $snippet "{ word shift }" } " - " { $snippet "word" } " is applied to the top of the stack and the result is shifted to the left by " { $snippet "shift" } " bits and bitor'd with the bit field" }
        { { $snippet "shift" } " - the top of the stack is shifted to the left by " { $snippet "shift" } " bits and bitor'd with the bit field" }
        { { $snippet "{ constant shift }" } " - " { $snippet "constant" } " is shifted to the left by " { $snippet "shift" } " bits and bitor'd with the bit field" }
    }
    "The bit field specifier is processed in order, so stack values are taken from left to right."
}
{ $examples
    "Consider the following specification:"
    { $list
        { "bits 0-10 are set to the value of " { $snippet "x" } }
        { "bits 11-14 are set to the value of " { $snippet "y" } }
        { "bit 15 is always on" }
        { "bits 16-20 are set to the value of " { $snippet "fooify" } " applied to " { $snippet "z" } }
    }
    "Such a bit field construction can be specified with a word like the following:"
    { $example
        "USING: math math.bitwise prettyprint ;"
        "IN: math.bitwise.examples"
        ": fooify ( x -- y ) 0b1111 bitand ;"
        ": baz-bitfield* ( x y z -- n )"
        "    {"
        "        0"
        "        11"
        "        { 1 15 }"
        "        { fooify 16 }"
        "    } bitfield* ;"
        "1 2 3 baz-bitfield* ."
        "233473"
    }
    "Put a 1 at bit 1, put the 1 from the stack at bit 5, square the 3 and put it at bit 8:"
    { $example
        "USING: math math.bitwise prettyprint ;"
        "1 3"
        "    {"
        "        { 1 2 }"
        "        5"
        "        { sq 8 }"
        "    } bitfield* .b"
        "0b100100100100"
    }
} ;

{ bitfield bitfield* } related-words

HELP: bits
{ $values { "m" integer } { "n" integer } { "m'" integer } }
{ $description "Keep only " { $snippet "n" } " bits from the integer " { $snippet "m" } ". For negative numbers, represent the number as two's complement (a positive integer representing a negative integer)." }
{ $examples
    { $example
        "USING: math.bitwise prettyprint ;"
        "0x123abcdef 16 bits .h"
        "0xcdef"
    }
    { $example
        "USING: math.bitwise prettyprint ;"
        "-2 16 bits .h"
        "0xfffe"
    }
} ;

HELP: bit-range
{ $values { "x" integer } { "high" integer } { "low" integer } { "y" integer } }
{ $description "Extract a range of bits from an integer, inclusive of each boundary." }
{ $example "USING: math.bitwise prettyprint ;" "0b1100 3 2 bit-range .b" "0b11" } ;

HELP: bitroll
{ $values { "x" integer } { "s" "a shift integer" } { "w" "a wrap integer" } { "y" integer }
}
{ $description "Roll " { $snippet "n" } " by " { $snippet "s" } " bits to the left, wrapping around after " { $snippet "w" } " bits." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;" "1 -1 32 bitroll .b" "0b10000000000000000000000000000000" }
    { $example "USING: math.bitwise prettyprint ;" "0xffff0000 8 32 bitroll .h" "0xff0000ff" }
} ;

{ bit? set-bit clear-bit } related-words

HELP: bit-count
{ $values
    { "obj" object }
    { "n" integer }
}
{ $description "Returns the number of set bits as an object. This word only works on non-negative integers or objects that can be represented as a byte-array." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
               "0xf0 bit-count ."
               "4"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "-1 32 bits bit-count ."
               "32"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "B{ 1 0 1 } bit-count ."
               "2"
    }
} ;

HELP: bitroll-32
{ $values
    { "m" integer } { "s" integer }
    { "n" integer }
}
{ $description "Rolls the number " { $snippet "m" } " by " { $snippet "s" } " bits to the left, wrapping around after 32 bits." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
               "0x1 10 bitroll-32 .h"
               "0x400"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "0x1 -10 bitroll-32 .h"
               "0x400000"
    }
} ;

HELP: bitroll-64
{ $values
    { "m" integer } { "s" "a shift integer" }
    { "n" integer }
}
{ $description "Rolls the number " { $snippet "m" } " by " { $snippet "s" } " bits to the left, wrapping around after 64 bits." }
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
               "0x1 10 bitroll-64 .h"
               "0x400"
    }
    { $example "USING: math.bitwise prettyprint ;"
               "0x1 -10 bitroll-64 .h"
               "0x40000000000000"
    }
} ;

{ bitroll bitroll-32 bitroll-64 } related-words

HELP: clear-bit
{ $values
    { "x" integer } { "n" integer }
    { "y" integer }
}
{ $description "Sets the " { $snippet "n" } "th bit of " { $snippet "x" } " to zero." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 7 clear-bit .h"
        "0x7f"
    }
} ;

HELP: symbols>flags
{ $values { "symbols" sequence } { "assoc" assoc } { "flag-bits" integer } }
{ $description "Constructs an integer value by mapping the values in the " { $snippet "symbols" } " sequence to integer values using " { $snippet "assoc" } " and " { $link bitor } "ing the values together." }
{ $examples
    { $example "USING: math.bitwise prettyprint ui.gadgets.worlds ;"
        "IN: scratchpad"
        "CONSTANT: window-controls>flags H{"
        "    { close-button 1 }"
        "    { minimize-button 2 }"
        "    { maximize-button 4 }"
        "    { resize-handles 8 }"
        "    { small-title-bar 16 }"
        "    { normal-title-bar 32 }"
        "}"
        "{ resize-handles close-button small-title-bar } window-controls>flags symbols>flags ."
        "25"
    }
} ;

HELP: >even
{ $values
    { "m" integer }
    { "n" integer }
}
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
        "7 >even ."
        "6"
    }
}
{ $description "Sets the lowest bit in the integer to 0, which either does nothing or outputs 1 less than the input integer." } ;

HELP: >odd
{ $values
    { "m" integer }
    { "n" integer }
}
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
        "4 >odd ."
        "5"
    }
}
{ $description "Sets the lowest bit in the integer to 1, which either does nothing or outputs 1 more than the input integer." } ;

HELP: >signed
{ $values
    { "x" integer } { "n" integer }
    { "y" integer }
}
{ $examples
    { $example "USING: math.bitwise prettyprint ;"
        "0xff 8 >signed ."
        "-1"
    }
    { $example "USING: math.bitwise prettyprint ;"
        "0xf0 4 >signed ."
        "0"
    }
}
{ $description "Interprets a number " { $snippet "x" } " as an " { $snippet "n" } "-bit number and converts it to a negative number if the topmost bit is set." } ;

{ >signed bits } related-words

HELP: mask
{ $values
    { "x" integer } { "n" integer }
    { "y" integer }
}
{ $description "After the operation, only the bits that were set in both the mask and the original number are set." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0b11111111 0b101 mask .b"
        "0b101"
    }
} ;

HELP: mask-bit
{ $values
    { "m" integer } { "n" integer }
    { "m'" integer }
}
{ $description "Turns off all bits besides the " { $snippet "n" } "th bit." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 2 mask-bit .b"
        "0b100"
    }
} ;

HELP: mask?
{ $values
    { "x" integer } { "n" integer }
    { "?" boolean }
}
{ $description "Returns true if all of the bits in the mask " { $snippet "n" } " are set in the integer input " { $snippet "x" } "." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 0xf mask? ."
        "t"
    }

    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xf0 0x1 mask? ."
        "f"
    }
} ;

HELP: even-parity?
{ $values
    { "obj" object }
    { "?" boolean }
}
{ $description "Returns true if the number of set bits in an object is even." } ;

HELP: odd-parity?
{ $values
    { "obj" object }
    { "?" boolean }
}
{ $description "Returns true if the number of set bits in an object is odd." } ;

HELP: on-bits
{ $values
    { "m" integer }
    { "n" integer }
}
{ $description "Returns an integer with " { $snippet "m" } " bits set." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "6 on-bits .h"
        "0x3f"
    }
    { $example "USING: math.bitwise kernel prettyprint ;"
        "64 on-bits .h"
        "0xffffffffffffffff"
    }
} ;

HELP: toggle-bit
{ $values
    { "m" integer }
    { "n" integer }
    { "m'" integer }
}
{ $description "Toggles the " { $snippet "n" } "th bit of an integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0 3 toggle-bit .b"
        "0b1000"
    }
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0b1000 3 toggle-bit .b"
        "0b0"
    }
} ;

HELP: set-bit
{ $values
    { "x" integer } { "n" integer }
    { "y" integer }
}
{ $description "Sets the " { $snippet "n" } "th bit of " { $snippet "x" } "." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0 5 set-bit .h"
        "0x20"
    }
} ;

HELP: shift-mod
{ $values
    { "m" integer } { "s" integer } { "w" integer }
    { "n" integer }
}
{ $description "Calls " { $link shift } " on " { $snippet "n" } " and " { $snippet "s" } ", wrapping the result to " { $snippet "w" } " bits." } ;

HELP: unmask
{ $values
    { "x" integer } { "n" integer }
    { "y" integer }
}
{ $description "Clears the bits in " { $snippet "x" } " if they are set in the mask " { $snippet "n" } "." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 0x0f unmask .h"
        "0xf0"
    }
} ;

HELP: unmask?
{ $values
    { "x" integer } { "n" integer }
    { "?" boolean }
}
{ $description "Tests whether unmasking the bits in " { $snippet "x" } " would return an integer greater than zero." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xff 0x0f unmask? ."
        "t"
    }
} ;

HELP: w*
{ $values
    { "x" integer } { "y" integer }
    { "z" integer }
}
{ $description "Multiplies two integers and wraps the result to a 32-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xffffffff 0x2 w* ."
        "4294967294"
    }
} ;

HELP: w+
{ $values
    { "x" integer } { "y" integer }
    { "z" integer }
}
{ $description "Adds two integers and wraps the result to a 32-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xffffffff 0x2 w+ ."
        "1"
    }
} ;

HELP: w-
{ $values
    { "x" integer } { "y" integer }
    { "z" integer }
}
{ $description "Subtracts two integers and wraps the result to a 32-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0x0 0xff w- ."
        "4294967041"
    }
} ;

HELP: W*
{ $values
    { "x" integer } { "y" integer }
    { "z" integer }
}
{ $description "Multiplies two integers and wraps the result to a 64-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xffffffffffffffff 0x2 W* ."
        "18446744073709551614"
    }
} ;

HELP: W+
{ $values
    { "x" integer } { "y" integer }
    { "z" integer }
}
{ $description "Adds two integers and wraps the result to 64-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0xffffffffffffffff 0x2 W+ ."
        "1"
    }
} ;

HELP: W-
{ $values
    { "x" integer } { "y" integer }
    { "z" integer }
}
{ $description "Subtracts two integers and wraps the result to a 64-bit unsigned integer." }
{ $examples
    { $example "USING: math.bitwise kernel prettyprint ;"
        "0x0 0xff W- ."
        "18446744073709551361"
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
        "0xffff 8 wrap .h"
        "0x7"
    }
} ;

HELP: d>w/w
{ $values { "d" "a 64-bit integer" } { "w1" "a 32-bit integer" } { "w2" "a 32-bit integer" } }
{ $description "Outputs two integers, the least followed by the most significant 32 bits of the input." } ;

HELP: w>h/h
{ $values { "w" "a 32-bit integer" } { "h1" "a 16-bit integer" } { "h2" "a 16-bit integer" } }
{ $description "Outputs two integers, the least followed by the most significant 16 bits of the input." } ;

HELP: h>b/b
{ $values { "h" "a 16-bit integer" } { "b1" "an 8-bit integer" } { "b2" "an 8-bit integer" } }
{ $description "Outputs two integers, the least followed by the most significant 8 bits of the input." } ;

ARTICLE: "math-bitfields" "Constructing bit fields"
"Some applications, such as binary communication protocols and assemblers, need to construct integers from elaborate bit field specifications. Hand-coding this using " { $link shift } " and " { $link bitor } " results in repetitive code. A higher-level facility exists to factor out this repetition:"
{ $subsections bitfield } ;

ARTICLE: "math.bitwise" "Additional bitwise arithmetic"
"The " { $vocab-link "math.bitwise" } " vocabulary provides bitwise arithmetic words extending " { $link "bitwise-arithmetic" } ". They are useful for efficiency, low-level programming, and interfacing with C libraries."
$nl
"Setting and clearing bits:"
{ $subsections
    set-bit
    clear-bit
}
"Testing if bits are set:"
{ $subsections
    bit?
}
"Extracting bits from an integer:"
{ $subsections
    bit-range
    bits
}
"Toggling a bit:"
{ $subsections
    toggle-bit
}
"Operations with bitmasks:"
{ $subsections
    mask
    unmask
    mask?
    unmask?
}
"Generating an integer with n set bits:"
{ $subsections on-bits }
"Counting the number of set bits:"
{ $subsections bit-count }
"Testing the parity of an object:"
{ $subsections even-parity? odd-parity? }
"More efficient modding by powers of two:"
{ $subsections wrap }
"Bit-rolling:"
{ $subsections
    bitroll
    bitroll-32
    bitroll-64
}
"32-bit arithmetic:"
{ $subsections
    w+
    w-
    w*
}
"64-bit arithmetic:"
{ $subsections
    W+
    W-
    W*
}
"Words for taking larger integers apart into smaller integers:"
{ $subsections
    d>w/w
    w>h/h
    h>b/b
}
"Converting a number to the nearest even/odd/signed:"
{ $subsections
    >even
    >odd
    >signed
}
"Bitfields:"
{ $subsections
    "math-bitfields"
} ;

ABOUT: "math.bitwise"
