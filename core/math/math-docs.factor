USING: help.markup help.syntax kernel sequences quotations
math.private byte-arrays io.binary ;
IN: math

HELP: number=
{ $values { "x" number } { "y" number } { "?" "a boolean" } }
{ $description "Tests if two numbers have the same numeric value." }
{ $notes "This word differs from " { $link = } " in that it disregards differences in type when comparing numbers." }
{ $examples
    { $example "USING: math prettyprint ;" "3.0 3 number= ." "t" }
    { $example "USING: kernel math prettyprint ;" "3.0 3 = ." "f" }
} ;

HELP: <
{ $values { "x" real } { "y" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is less than " { $snippet "y" } "." } ;

HELP: <=
{ $values { "x" real } { "y" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is less than or equal to " { $snippet "y" } "." } ;

HELP: >
{ $values { "x" real } { "y" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is greater than " { $snippet "y" } "." } ;

HELP: >=
{ $values { "x" real } { "y" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is greater than or equal to " { $snippet "y" } "." } ;


HELP: +
{ $values { "x" number } { "y" number } { "z" number } }
{ $description
    "Adds two numbers."
    { $list
        "Addition of fixnums may overflow and convert the result to a bignum."
        "Addition of bignums always yields a bignum."
        "Addition of floats always yields a float."
        "Addition of ratios and complex numbers proceeds using the relevant mathematical rules."
    }
} ;

HELP: -
{ $values { "x" number } { "y" number } { "z" number } }
{ $description
    "Subtracts " { $snippet "y" } " from " { $snippet "x" } "."
    { $list
        "Subtraction of fixnums may overflow and convert the result to a bignum."
        "Subtraction of bignums always yields a bignum."
        "Subtraction of floats always yields a float."
        "Subtraction of ratios and complex numbers proceeds using the relevant mathematical rules."
    }
} ;

HELP: *
{ $values { "x" number } { "y" number } { "z" number } }
{ $description
    "Multiplies two numbers."
    { $list
        "Multiplication of fixnums may overflow and convert the result to a bignum."
        "Multiplication of bignums always yields a bignum."
        "Multiplication of floats always yields a float."
        "Multiplication of ratios and complex numbers proceeds using the relevant mathematical rules."
    }
} ;

HELP: /
{ $values { "x" number } { "y" number } { "z" number } }
{ $description
    "Divides " { $snippet "x" } " by " { $snippet "y" } ", retaining as much precision as possible."
    { $list
        "Division of fixnums may yield a ratio, or overflow and yield a bignum."
        "Division of bignums may yield a ratio."
        "Division of floats always yields a float."
        "Division of ratios and complex numbers proceeds using the relevant mathematical rules."
    }
}
{ $see-also "division-by-zero" } ;

HELP: /i
{ $values { "x" real } { "y" real } { "z" integer } }
{ $description
    "Divides " { $snippet "x" } " by " { $snippet "y" } ", truncating the result to an integer."
}
{ $see-also "division-by-zero" } ;

HELP: /f
{ $values { "x" real } { "y" real } { "z" float } }
{ $description
    "Divides " { $snippet "x" } " by " { $snippet "y" } ", representing the result as a floating point number."
}
{ $see-also "division-by-zero" } ;

HELP: mod
{ $values { "x" rational } { "y" rational } { "z" rational } }
{ $description
    "Computes the remainder of dividing " { $snippet "x" } " by " { $snippet "y" } ", with the remainder being negative if " { $snippet "x" } " is negative."
    { $list 
        "Modulus of fixnums always yields a fixnum."
        "Modulus of bignums always yields a bignum."    
        { "Modulus of rationals always yields a rational. In this case, the remainder is computed using the formula " { $snippet "x - (x mod y) * y" } "." }
    }
}
{ $see-also "division-by-zero" rem } ;

HELP: /mod
{ $values { "x" integer } { "y" integer } { "z" integer } { "w" integer } }
{ $description
    "Computes the quotient " { $snippet "z" } " and remainder " { $snippet "w" } " of dividing " { $snippet "x" } " by " { $snippet "y" } ", with the remainder being negative if " { $snippet "x" } " is negative."
    { $list 
        "The quotient of two fixnums may overflow and yield a bignum; the remainder is always a fixnum"
        "The quotient and remainder of two bignums is always a bignum."            
    }
}
{ $see-also "division-by-zero" } ;

HELP: bitand
{ $values { "x" integer } { "y" integer } { "z" integer } }
{ $description "Outputs a new integer where each bit is set if and only if the corresponding bit is set in both inputs." }
{ $examples
    { $example "USING: math prettyprint ;" "BIN: 101 BIN: 10 bitand .b" "0" }
    { $example "USING: math prettyprint ;" "BIN: 110 BIN: 10 bitand .b" "10" }
}
{ $notes "This word implements bitwise and, so applying it to booleans will throw an error. Boolean and is the " { $link and } " word." } ;

HELP: bitor
{ $values { "x" integer } { "y" integer } { "z" integer } }
{ $description "Outputs a new integer where each bit is set if and only if the corresponding bit is set in at least one of the inputs." }
{ $examples
    { $example "USING: math prettyprint ;" "BIN: 101 BIN: 10 bitor .b" "111" }
    { $example "USING: math prettyprint ;" "BIN: 110 BIN: 10 bitor .b" "110" }
}
{ $notes "This word implements bitwise inclusive or, so applying it to booleans will throw an error. Boolean inclusive or is the " { $link and } " word." } ;

HELP: bitxor
{ $values { "x" integer } { "y" integer } { "z" integer } }
{ $description "Outputs a new integer where each bit is set if and only if the corresponding bit is set in exactly one of the inputs." }
{ $examples
    { $example "USING: math prettyprint ;" "BIN: 101 BIN: 10 bitxor .b" "111" }
    { $example "USING: math prettyprint ;" "BIN: 110 BIN: 10 bitxor .b" "100" }
}
{ $notes "This word implements bitwise exclusive or, so applying it to booleans will throw an error. Boolean exclusive or is the " { $link xor } " word." } ;

HELP: shift
{ $values { "x" integer } { "n" integer } { "y" integer } }
{ $description "Shifts " { $snippet "x" } " to the left by " { $snippet "n" } " bits if " { $snippet "n" } " is positive, or " { $snippet "-n" } " bits to the right if " { $snippet "n" } " is negative. A left shift of a fixnum may overflow, yielding a bignum. A right shift may result in bits “falling off” the right hand side and being discarded." }
{ $examples { $example "USING: math prettyprint ;" "BIN: 101 5 shift .b" "10100000" } { $example "USING: math prettyprint ;" "BIN: 11111 -2 shift .b" "111" } } ;

HELP: bitnot
{ $values { "x" integer } { "y" integer } }
{ $description "Computes the bitwise complement of the input; that is, each bit in the input number is flipped." }
{ $notes "This word implements bitwise not, so applying it to booleans will throw an error. Boolean not is the " { $link not } " word."
$nl
"Due to the two's complement representation of signed integers, the following two lines are equivalent:" { $code "bitnot" "neg 1-" } } ;

HELP: bit?
{ $values { "x" integer } { "n" integer } { "?" "a boolean" } }
{ $description "Tests if the " { $snippet "n" } "th bit of " { $snippet "x" } " is set." }
{ $examples { $example "USING: math prettyprint ;" "BIN: 101 2 bit? ." "t" } } ;

HELP: log2
{ $values { "x" "a positive integer" } { "n" integer } }
{ $description "Outputs the largest integer " { $snippet "n" } " such that " { $snippet "2^n" } " is less than or equal to " { $snippet "x" } "." }
{ $errors "Throws an error if " { $snippet "x" } " is zero or negative." } ;

HELP: 1+
{ $values { "x" number } { "y" number } }
{ $description
    "Increments a number by 1. The following two lines are equivalent:"
    { $code "1+" "1 +" }
    "There is no difference in behavior or efficiency."
} ;

HELP: 1-
{ $values { "x" number } { "y" number } }
{ $description
    "Decrements a number by 1. The following two lines are equivalent:"
    { $code "1-" "1 -" }
    "There is no difference in behavior or efficiency."
} ;

HELP: ?1+
{ $values { "x" { $maybe number } } { "y" number } }
{ $description "If the input is not " { $link f } ", adds one. Otherwise, outputs a " { $snippet "0" } "." } ;

HELP: sq
{ $values { "x" number } { "y" number } }
{ $description "Multiplies a number by itself." } ;

HELP: neg
{ $values { "x" number } { "-x" number } }
{ $description "Computes a number's additive inverse." } ;

HELP: recip
{ $values { "x" number } { "y" number } }
{ $description "Computes a number's multiplicative inverse." }
{ $errors "Throws an error if " { $snippet "x" } " is the integer 0." } ;

HELP: rem
{ $values { "x" rational } { "y" rational } { "z" rational } }
{ $description
    "Computes the remainder of dividing " { $snippet "x" } " by " { $snippet "y" } ", with the remainder always positive."
    { $list 
        "Given fixnums, always yields a fixnum."
        "Given bignums, always yields a bignum."
        "Given rationals, always yields a rational."    
    }
}
{ $see-also "division-by-zero" mod } ;

HELP: sgn
{ $values { "x" real } { "n" "-1, 0 or 1" } }
{ $description
    "Outputs one of the following:"
    { $list
        "-1 if " { $snippet "x" } " is negative"
        "0 if " { $snippet "x" } " is equal to 0"
        "1 if " { $snippet "x" } " is positive"
    }
} ;

HELP: 2/
{ $values { "x" integer } { "y" integer } }
{ $description "Shifts " { $snippet "x" } " to the right by one bit." }
{ $examples
    { $example "USING: math prettyprint ;" "14 2/ ." "7" }
    { $example "USING: math prettyprint ;" "17 2/ ." "8" }
    { $example "USING: math prettyprint ;" "-17 2/ ." "-9" }
}
{ $notes "This word is not equivalent to " { $snippet "2 /" } " or " { $snippet "2 /i" } "; the name is historic and originates from the Forth programming language." } ;

HELP: 2^
{ $values { "n" "a positive integer" } { "2^n" "a positive integer" } }
{ $description "Computes two to the power of " { $snippet "n" } ". This word will only give correct results if " { $snippet "n" } " is greater than zero; for the general case, use " { $snippet  "2 swap ^" } "." } ;

HELP: zero?
{ $values { "x" number } { "?" "a boolean" } }
{ $description "Tests if the number is equal to zero." } ;

HELP: times
{ $values { "n" integer } { "quot" quotation } }
{ $description "Calls the quotation " { $snippet "n" } " times." }
{ $notes "If you need to pass the current index to the quotation, use " { $link each } "." }
{ $examples
    { $example "USING: io math ;" "3 [ \"Hi\" print ] times" "Hi\nHi\nHi" }
} ;

HELP: fp-special?
{ $values { "x" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is an IEEE special value (Not-a-Number or Infinity). While " { $snippet "x" } " can be any real number, this word will only ever yield true if " { $snippet "x" } " is a " { $link float } "." } ;

HELP: fp-nan?
{ $values { "x" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is an IEEE Not-a-Number value. While " { $snippet "x" } " can be any real number, this word will only ever yield true if " { $snippet "x" } " is a " { $link float } "." } ;

HELP: fp-qnan?
{ $values { "x" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is an IEEE Quiet Not-a-Number value. While " { $snippet "x" } " can be any real number, this word will only ever yield true if " { $snippet "x" } " is a " { $link float } "." } ;

HELP: fp-snan?
{ $values { "x" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is an IEEE Signaling Not-a-Number value. While " { $snippet "x" } " can be any real number, this word will only ever yield true if " { $snippet "x" } " is a " { $link float } "." } ;

HELP: fp-infinity?
{ $values { "x" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is an IEEE Infinity value. While " { $snippet "x" } " can be any real number, this word will only ever yield true if " { $snippet "x" } " is a " { $link float } "." }
{ $examples
    { $example "USING: math prettyprint ;" "1/0. fp-infinity? ." "t" }
    { $example "USING: io kernel math ;" "-1/0. [ fp-infinity? ] [ 0 < ] bi and [ \"negative infinity\" print ] when" "negative infinity" }
} ;

HELP: fp-nan-payload
{ $values { "x" real } { "bits" integer } }
{ $description "If " { $snippet "x" } " is an IEEE Not-a-Number value, returns the payload encoded in the value. Returns " { $link f } " if " { $snippet "x" } " is not a " { $link float } "." } ;

HELP: <fp-nan>
{ $values { "payload" integer } { "nan" float } }
{ $description "Constructs an IEEE Not-a-Number value with a payload of " { $snippet "payload" } "." }
{ $notes "A " { $snippet "payload" } " of " { $snippet "0" } " will construct an Infinity value." } ;

{ fp-special? fp-nan? fp-qnan? fp-snan? fp-infinity? fp-nan-payload <fp-nan> } related-words

HELP: next-float
{ $values { "m" float } { "n" float } }
{ $description "Returns the least representable " { $link float } " value greater than " { $snippet "m" } "." } ;

HELP: prev-float
{ $values { "m" float } { "n" float } }
{ $description "Returns the greatest representable " { $link float } " value less than " { $snippet "m" } "." } ;

{ next-float prev-float } related-words

HELP: real-part
{ $values { "z" number } { "x" real } }
{ $description "Outputs the real part of a complex number. This acts as the identity on real numbers." }
{ $examples { $example "USING: math prettyprint ; C{ 1 2 } real-part ." "1" } } ;

HELP: imaginary-part
{ $values { "z" number } { "y" real } }
{ $description "Outputs the imaginary part of a complex number. This outputs zero for real numbers." }
{ $examples
    { $example "USING: math prettyprint ; C{ 1 2 } imaginary-part ." "2" }
    { $example "USING: math prettyprint ; 3 imaginary-part ." "0" }
} ;

HELP: real
{ $class-description "The class of real numbers, which is a disjoint union of rationals and floats." } ;

HELP: number
{ $class-description "The class of numbers." } ;

HELP: next-power-of-2
{ $values { "m" "a non-negative integer" } { "n" "an integer" } }
{ $description "Outputs the smallest power of 2 greater than " { $snippet "m" } ". The output value is always at least 1." } ;

HELP: power-of-2?
{ $values { "n" integer } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "n" } " is a power of 2." } ;

HELP: each-integer
{ $values { "n" integer } { "quot" { $quotation "( i -- )" } } }
{ $description "Applies the quotation to each integer from 0 up to " { $snippet "n" } ", excluding " { $snippet "n" } "." }
{ $notes "This word is used to implement " { $link each } "." } ;

HELP: all-integers?
{ $values { "n" integer } { "quot" { $quotation "( i -- ? )" } } { "?" "a boolean" } }
{ $description "Applies the quotation to each integer from 0 up to " { $snippet "n" } ", excluding " { $snippet "n" } ". Iterationi stops when the quotation outputs " { $link f } " or the end is reached. If the quotation yields a false value for some integer, this word outputs " { $link f } ". Otherwise, this word outputs " { $link t } "." }
{ $notes "This word is used to implement " { $link all? } "." } ;

HELP: find-integer
{ $values { "n" integer } { "quot" { $quotation "( i -- ? )" } } { "i" "an integer or " { $link f } } }
{ $description "Applies the quotation to each integer from 0 up to " { $snippet "n" } ", excluding " { $snippet "n" } ". Iterationi stops when the quotation outputs a true value or the end is reached. If the quotation yields a true value for some integer, this word outputs that integer. Otherwise, this word outputs " { $link f } "." }
{ $notes "This word is used to implement " { $link find } "." } ;

HELP: find-last-integer
{ $values { "n" integer } { "quot" { $quotation "( i -- ? )" } } { "i" "an integer or " { $link f } } }
{ $description "Applies the quotation to each integer from " { $snippet "n" } " down to 0, inclusive. Iteration stops when the quotation outputs a true value or 0 is reached. If the quotation yields a true value for some integer, the word outputs that integer. Otherwise, the word outputs " { $link f } "." }
{ $notes "This word is used to implement " { $link find-last } "." } ;

HELP: byte-array>bignum
{ $values { "x" byte-array } { "y" bignum } }
{ $description "Converts a byte-array, interpreted as little-endian, into a bignum integer. User code should call " { $link le> } " or " { $link be> } " instead." } ;

ARTICLE: "division-by-zero" "Division by zero"
"Floating point division never raises an error if the denominator is zero. This means that if at least one of the two inputs to " { $link / } ", " { $link /f } " or " { $link mod } " is a float, the result will be a floating point infinity or not a number value."
$nl
"The behavior of integer division is hardware specific. On x86 processors, " { $link /i } " and " { $link mod } " raise an error if both inputs are integers and the denominator is zero. On PowerPC, integer division by zero yields a result of zero."
$nl
"On the other hand, the " { $link / } " word, when given integer arguments, implements a much more expensive division algorithm which always yields an exact rational answer, and this word always tests for division by zero explicitly." ;

ARTICLE: "number-protocol" "Number protocol"
"Math operations obey certain numerical upgrade rules. If one of the inputs is a bignum and the other is a fixnum, the latter is first coerced to a bignum; if one of the inputs is a float, the other is coerced to a float."
$nl
"Two examples where you should note the types of the inputs and outputs:"
{ $example "USE: classes" "3 >fixnum 6 >bignum * class ." "bignum" }
{ $example "1/2 2.0 + ." "2.5" }
"The following usual operations are supported by all numbers."
{ $subsection + }
{ $subsection - }
{ $subsection * }
{ $subsection / }
"Non-commutative operations take operands from the stack in the natural order; " { $snippet "6 2 /" } " divides 6 by 2."
{ $subsection "division-by-zero" }
"Real numbers (but not complex numbers) can be ordered:"
{ $subsection < }
{ $subsection <= }
{ $subsection > }
{ $subsection >= }
"Numbers can be compared for equality using " { $link = } ", or a less precise test which disregards types:"
{ $subsection number= } ;

ARTICLE: "modular-arithmetic" "Modular arithmetic"
{ $subsection mod }
{ $subsection rem }
{ $subsection /mod }
{ $subsection /i }
{ $see-also "integer-functions" } ;

ARTICLE: "bitwise-arithmetic" "Bitwise arithmetic"
"There are two ways of looking at an integer -- as an abstract mathematical entity, or as a string of bits. The latter representation motivates " { $emphasis "bitwise operations" } "."
{ $subsection bitand }
{ $subsection bitor }
{ $subsection bitxor }
{ $subsection bitnot }
{ $subsection shift }
{ $subsection 2/ }
{ $subsection 2^ }
{ $subsection bit? }
{ $subsection "math.bitwise" }
{ $subsection "math.bits" }
{ $see-also "booleans" } ;

ARTICLE: "arithmetic" "Arithmetic"
"Factor attempts to preserve natural mathematical semantics for numbers. Multiplying two large integers never results in overflow, and dividing two integers yields an exact ratio. Floating point numbers are also supported, along with complex numbers."
$nl
"Math words are in the " { $vocab-link "math" } " vocabulary. Implementation details are in the " { $vocab-link "math.private" } " vocabulary."
{ $subsection "number-protocol" }
{ $subsection "modular-arithmetic" }
{ $subsection "bitwise-arithmetic" }
{ $see-also "integers" "rationals" "floats" "complex-numbers" } ;

ABOUT: "arithmetic"

