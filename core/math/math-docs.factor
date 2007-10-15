USING: help.markup help.syntax kernel sequences quotations
math.private math.functions ;
IN: math

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
{ $example "3 >fixnum 6 >bignum * class ." "bignum" }
{ $example "1/2 2.0 + ." "4.5" }
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
"Inexact comparison:"
{ $subsection ~ } ;

ARTICLE: "modular-arithmetic" "Modular arithmetic"
{ $subsection mod }
{ $subsection rem }
{ $subsection /mod }
{ $subsection /i }
{ $subsection mod-inv }
{ $subsection ^mod }
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
{ $see-also "conditionals" } ;

ARTICLE: "arithmetic" "Arithmetic"
"Factor attempts to preserve natural mathematical semantics for numbers. Multiplying two large integers never results in overflow, and dividing two integers yields an exact ratio. Floating point numbers are also supported, along with complex numbers."
$nl
"Math words are in the " { $vocab-link "math" } " vocabulary. Implementation details are in the " { $vocab-link "math.private" } " vocabulary."
{ $subsection "number-protocol" }
{ $subsection "modular-arithmetic" }
{ $subsection "bitwise-arithmetic" }
{ $see-also "integers" "rationals" "floats" "complex-numbers" } ;

ABOUT: "arithmetic"

HELP: number=
{ $values { "x" number } { "y" number } { "?" "a boolean" } }
{ $description "Tests if two numbers have the same numerical value. If either input is not a number, outputs " { $link f } "." }
{ $notes "Do not call this word directly. Calling " { $link = } " has the same effect and is more concise." } ;

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
{ $values { "x" real } { "y" real } { "z" real } }
{ $description
    "Divides " { $snippet "x" } " by " { $snippet "y" } ", truncating the result to an integer."
    { $list
        "Integer division of fixnums may overflow and yield a bignum."
        "Integer division of bignums always yields a bignum."
        "Integer division of floats always yields a float."
        "Integer division of ratios and complex numbers proceeds using the relevant mathematical rules."
    }
}
{ $see-also "division-by-zero" } ;

HELP: /f
{ $values { "x" real } { "y" real } { "z" real } }
{ $description
    "Divides " { $snippet "x" } " by " { $snippet "y" } ", representing the result as a floating point number."
    { $list 
        "Integer division of fixnums may overflow and yield a bignum."
        "Integer division of bignums always yields a bignum."            
        "Integer division of floats always yields a float."
        "Integer division of ratios and complex numbers proceeds using the relevant mathematical rules."
    }
}
{ $see-also "division-by-zero" } ;

HELP: mod
{ $values { "x" integer } { "y" integer } { "z" integer } }
{ $description
    "Computes the remainder of dividing " { $snippet "x" } " by " { $snippet "y" } ", with the remainder being negative if " { $snippet "x" } " is negative."
    { $list 
        "Modulus of fixnums always yields a fixnum."
        "Modulus of bignums always yields a bignum."            
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
    { $example "BIN: 101 BIN: 10 bitand .b" "0" }
    { $example "BIN: 110 BIN: 10 bitand .b" "10" }
}
{ $notes "This word implements bitwise and, so applying it to booleans will throw an error. Boolean and is the " { $link and } " word." } ;

HELP: bitor
{ $values { "x" integer } { "y" integer } { "z" integer } }
{ $description "Outputs a new integer where each bit is set if and only if the corresponding bit is set in at least one of the inputs." }
{ $examples
    { $example "BIN: 101 BIN: 10 bitor .b" "111" }
    { $example "BIN: 110 BIN: 10 bitor .b" "110" }
}
{ $notes "This word implements bitwise inclusive or, so applying it to booleans will throw an error. Boolean inclusive or is the " { $link and } " word." } ;

HELP: bitxor
{ $values { "x" integer } { "y" integer } { "z" integer } }
{ $description "Outputs a new integer where each bit is set if and only if the corresponding bit is set in exactly one of the inputs." }
{ $examples
    { $example "BIN: 101 BIN: 10 bitxor .b" "111" }
    { $example "BIN: 110 BIN: 10 bitxor .b" "100" }
}
{ $notes "This word implements bitwise exclusive or, so applying it to booleans will throw an error. Boolean exclusive or is the " { $link xor } " word." } ;

HELP: shift
{ $values { "x" integer } { "n" integer } { "y" integer } }
{ $description "Shifts " { $snippet "x" } " to the left by " { $snippet "y" } " bits if " { $snippet "y" } " is positive, or " { $snippet "-y" } " bits to the right if " { $snippet "y" } " is negative. A left shift of a fixnum may overflow, yielding a bignum. A right shift may result in bits ``falling off'' the right hand side and being discarded." }
{ $examples { $example "BIN: 101 5 shift .b" "10100000" } { $example "BIN: 11111 -2 shift .b" "111" } } ;

HELP: bitnot
{ $values { "x" integer } { "y" integer } }
{ $description "Computes the bitwise complement of the input; that is, each bit in the input number is flipped." }
{ $notes "This word implements bitwise not, so applying it to booleans will throw an error. Boolean not is the " { $link not } " word."
$nl
"Due to the two's complement representation of signed integers, the following two lines are equivalent:" { $code "bitnot" "neg 1-" } } ;

HELP: bit?
{ $values { "x" integer } { "n" integer } { "?" "a boolean" } }
{ $description "Tests if the " { $snippet "n" } "th bit of " { $snippet "x" } " is set." }
{ $examples { $example "BIN: 101 3 bit? ." "t" } } ;

HELP: log2
{ $values { "n" "a positive integer" } { "b" integer } }
{ $description "Outputs the largest integer " { $snippet "b" } " such that " { $snippet "2^b" } " is less than " { $snippet "n" } "." }
{ $errors "Throws an error if " { $snippet "n" } " is zero or negative." } ;

HELP: 1+
{ $values { "x" number } { "y" number } }
{ $description
    "Increments a number by 1. The following two lines are equivalent, but the first is more efficient:"
    { $code "1+" "1 +" }
} ;

HELP: 1-
{ $values { "x" number } { "y" number } }
{ $description
    "Decrements a number by 1. The following two lines are equivalent, but the first is more efficient:"
    { $code "1-" "1 -" }
} ;

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

HELP: max
{ $values { "x" real } { "y" real } { "z" real } }
{ $description "Outputs the greatest of two real numbers." } ;

HELP: min
{ $values { "x" real } { "y" real } { "z" real } }
{ $description "Outputs the smallest of two real numbers." } ;

HELP: between?
{ $values { "x" real } { "y" real } { "z" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is in the interval " { $snippet "[y,z]" } "." }
{ $notes "As per the closed interval notation, the end-points are included in the interval." } ;

HELP: rem
{ $values { "x" integer } { "y" integer } { "z" integer } }
{ $description
    "Computes the remainder of dividing " { $snippet "x" } " by " { $snippet "y" } ", with the remainder always positive."
    { $list 
        "Modulus of fixnums always yields a fixnum."
        "Modulus of bignums always yields a bignum."            
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
    { $example "14 2/ ." "7" }
    { $example "17 2/ ." "8" }
    { $example "-17 2/ ." "-9" }
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
{ $notes "If you need to pass the current index to the quotation, use " { $link each } "." } ;

HELP: [-]
{ $values { "x" real } { "y" real } { "z" real } }
{ $description "Subtracts " { $snippet "y" } " from " { $snippet "x" } ". If the result is less than zero, outputs zero." } ;

HELP: fp-nan?
{ $values { "x" real } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is an IEEE Not-a-Number value. While " { $snippet "x" } " can be any real number, this word will only ever yield true if " { $snippet "x" } " is a " { $link float } "." } ;

HELP: real ( z -- x )
{ $values { "z" number } { "x" real } }
{ $description "Outputs the real part of a complex number. This acts as the identity on real numbers." }
{ $class-description "The class of real numbers, which is a disjoint union of rationals and floats." } ;

HELP: imaginary ( z -- y )
{ $values { "z" number } { "y" real } }
{ $description "Outputs the imaginary part of a complex number. This outputs zero for real numbers." } ;

HELP: number
{ $class-description "The class of numbers." } ;

HELP: next-power-of-2
{ $values { "m" "a non-negative integer" } { "n" "an integer" } }
{ $description "Outputs the smallest power of 2 greater than " { $snippet "m" } ". The output value is always at least 1." } ;

HELP: each-integer
{ $values { "n" integer } { "quot" "a quotation with stack effect " { $snippet "( i -- )" } } }
{ $description "Applies the quotation to each integer from 0 up to " { $snippet "n" } ", excluding " { $snippet "n" } "." }
{ $notes "This word is used to implement " { $link each } "." } ;

HELP: all-integers?
{ $values { "n" integer } { "quot" "a quotation with stack effect " { $snippet "( i -- ? )" } } { "i" "an integer or " { $link f } } }
{ $description "Applies the quotation to each integer from 0 up to " { $snippet "n" } ", excluding " { $snippet "n" } ". Iterationi stops when the quotation outputs " { $link f } " or the end is reached. If the quotation yields a false value for some integer, this word outputs " { $link f } ". Otherwise, this word outputs " { $link t } "." }
{ $notes "This word is used to implement " { $link all? } "." } ;

HELP: find-integer
{ $values { "n" integer } { "quot" "a quotation with stack effect " { $snippet "( i -- ? )" } } { "i" "an integer or " { $link f } } }
{ $description "Applies the quotation to each integer from 0 up to " { $snippet "n" } ", excluding " { $snippet "n" } ". Iterationi stops when the quotation outputs a true value or the end is reached. If the quotation yields a true value for some integer, this word outputs that integer. Otherwise, this word outputs " { $link f } "." }
{ $notes "This word is used to implement " { $link find } "." } ;

HELP: find-last-integer
{ $values { "n" integer } { "quot" "a quotation with stack effect " { $snippet "( i -- ? )" } } { "i" "an integer or " { $link f } } }
{ $description "Applies the quotation to each integer from " { $snippet "n" } " down to 0, inclusive. Iteration stops when the quotation outputs a true value or 0 is reached. If the quotation yields a true value for some integer, the word outputs that integer. Otherwise, the word outputs " { $link f } "." }
{ $notes "This word is used to implement " { $link find-last } "." } ;
