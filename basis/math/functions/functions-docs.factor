USING: help.markup help.syntax kernel math math.order
sequences quotations math.functions.private math.constants ;
IN: math.functions

ARTICLE: "integer-functions" "Integer functions"
{ $subsections
    align
    gcd
    log2
    next-power-of-2
}
"Modular exponentiation:"
{ $subsections ^mod mod-inv }
"Tests:"
{ $subsections
    power-of-2?
    even?
    odd?
    divisor?
}
"Function variants:"
{ $subsections
    integer-log2
    integer-log10
    integer-sqrt
} ;

ARTICLE: "arithmetic-functions" "Arithmetic functions"
"Computing additive and multiplicative inverses:"
{ $subsections neg recip }
"Complex conjugation:"
{ $subsections conjugate }
"Tests:"
{ $subsections zero? between? }
"Control flow:"
{ $subsections
    if-zero
    when-zero
    unless-zero
}
"Sign:"
{ $subsections sgn }
"Rounding:"
{ $subsections
    ceiling
    floor
    truncate
    round
    round-to-decimal
    round-to-step
}
"Inexact comparison:"
{ $subsections ~ }
"Numbers implement the " { $link "math.order" } ", therefore operations such as " { $link min } " and " { $link max } " can be used with numbers." ;

ARTICLE: "power-functions" "Powers and logarithms"
"Squares:"
{ $subsections sq sqrt }
"Exponential and natural logarithm:"
{ $subsections e^ cis log }
"Other logarithms:"
{ $subsections log1+ log10 logn }
"Raising a number to a power:"
{ $subsections ^ e^ 10^ }
"Logistics functions:"
{ $subsections sigmoid }
"Finding the root of a number:"
{ $subsections nth-root }
"Converting between rectangular and polar form:"
{ $subsections
    abs
    absq
    arg
    >polar
    polar>
} ;

ARTICLE: "trig-hyp-functions" "Trigonometric and hyperbolic functions"
"Trigonometric functions:"
{ $subsections cos sin tan }
"Reciprocals:"
{ $subsections sec cosec cot }
"Inverses:"
{ $subsections acos asin atan }
"Inverse reciprocals:"
{ $subsections asec acosec acot }
"Hyperbolic functions:"
{ $subsections cosh sinh tanh }
"Reciprocals:"
{ $subsections sech cosech coth }
"Inverses:"
{ $subsections acosh asinh atanh }
"Inverse reciprocals:"
{ $subsections asech acosech acoth } ;

ARTICLE: "math-functions" "Mathematical functions"
{ $subsections
    "integer-functions"
    "arithmetic-functions"
    "power-functions"
    "trig-hyp-functions"
} ;

ABOUT: "math-functions"

HELP: align
{ $values { "m" integer } { "w" "a power of 2" } { "n" "an integer multiple of " { $snippet "w" } } }
{ $description "Outputs the least multiple of " { $snippet "w" } " greater than " { $snippet "m" } "." }
{ $notes "This word will give an incorrect result if " { $snippet "w" } " is not a power of 2." } ;

HELP: e^
{ $values { "x" number } { "e^x" number } }
{ $description "Exponential function, raises " { $link e } " to the power of " { $snippet "x" } "." } ;

HELP: frexp
{ $values { "x" number } { "y" float } { "exp" integer } }
{ $description "Break the number " { $snippet "x" } " into a normalized fraction " { $snippet "y" } " and an integral power of 2 " { $snippet "e^" } "." $nl "The function returns a number " { $snippet "y" } " in the interval [1/2, 1) or 0, and a number " { $snippet "exp" } " such that " { $snippet "x = y*(2**exp)" } "." } ;

HELP: ldexp
{ $values { "x" number } { "exp" number } { "y" number } }
{ $description "Multiply " { $snippet "x" } " by " { $snippet "2^exp" } "." }
{ $notes { $link ldexp } " is the inverse of " { $link frexp } "." } ;

HELP: log
{ $values { "x" number } { "y" number } }
{ $description "Natural logarithm function. Outputs negative infinity if " { $snippet "x" } " is 0." } ;

HELP: logn
{ $values { "x" number } { "n" number } { "y" number } }
{ $description "Finds the base " { $snippet "n" } " logarithm of " { $snippet "x" } "." } ;

HELP: log1+
{ $values { "x" number } { "y" number } }
{ $description "Takes the natural logarithm of " { $snippet "1 + x" } ". Outputs negative infinity if " { $snippet "1 + x" } " is zero. This word may be more accurate than " { $snippet "1 + log" } " for very small values of " { $snippet "x" } "." } ;

HELP: log10
{ $values { "x" number } { "y" number } }
{ $description "Logarithm function base 10. Outputs negative infinity if " { $snippet "x" } " is 0." } ;

HELP: lgamma
{ $values { "x" number } { "y" number } }
{ $description "Outputs the logarithm of the gamma function of " { $snippet "x" } } ;

HELP: sqrt
{ $values { "x" number } { "y" number } }
{ $description "Square root function." } ;

HELP: cosh
$values-x/y
{ $description "Hyperbolic cosine." } ;

HELP: sech
$values-x/y
{ $description "Hyperbolic secant." } ;

HELP: sinh
$values-x/y
{ $description "Hyperbolic sine." } ;

HELP: cosech
$values-x/y
{ $description "Hyperbolic cosecant." } ;

HELP: tanh
$values-x/y
{ $description "Hyperbolic tangent." } ;

HELP: coth
$values-x/y
{ $description "Hyperbolic cotangent." } ;

HELP: cos
$values-x/y
{ $description "Trigonometric cosine." } ;

HELP: sec
$values-x/y
{ $description "Trigonometric secant." } ;

HELP: sin
$values-x/y
{ $description "Trigonometric sine." } ;

HELP: cosec
$values-x/y
{ $description "Trigonometric cosecant." } ;

HELP: tan
$values-x/y
{ $description "Trigonometric tangent." } ;

HELP: cot
$values-x/y
{ $description "Trigonometric cotangent." } ;

HELP: acosh
$values-x/y
{ $description "Inverse hyperbolic cosine." } ;

HELP: asech
$values-x/y
{ $description "Inverse hyperbolic secant." } ;

HELP: asinh
$values-x/y
{ $description "Inverse hyperbolic sine." } ;

HELP: acosech
$values-x/y
{ $description "Inverse hyperbolic cosecant." } ;

HELP: atanh
$values-x/y
{ $description "Inverse hyperbolic tangent." } ;

HELP: acoth
$values-x/y
{ $description "Inverse hyperbolic cotangent." } ;

HELP: acos
$values-x/y
{ $description "Inverse trigonometric cosine." } ;

HELP: asec
$values-x/y
{ $description "Inverse trigonometric secant." } ;

HELP: asin
$values-x/y
{ $description "Inverse trigonometric sine." } ;

HELP: acosec
$values-x/y
{ $description "Inverse trigonometric cosecant." } ;

HELP: atan
$values-x/y
{ $description "Inverse trigonometric tangent." } ;

HELP: acot
$values-x/y
{ $description "Inverse trigonometric cotangent." } ;

HELP: conjugate
{ $values { "z" number } { "z*" number } }
{ $description "Computes the complex conjugate by flipping the sign of the imaginary part of " { $snippet "z" } "." } ;

HELP: arg
{ $values { "z" number } { "arg" "a number in the interval " { $snippet "(-pi,pi]" } } }
{ $description "Computes the complex argument." } ;

HELP: >polar
{ $values { "z" number } { "abs" "a non-negative real number" } { "arg" "a number in the interval " { $snippet "(-pi,pi]" } } }
{ $description "Converts a complex number into an absolute value and argument (polar form)." } ;

HELP: cis
{ $values { "arg" "a real number" } { "z" "a complex number on the unit circle" } }
{ $description "Computes a point on the unit circle using Euler's formula for " { $snippet "e^(arg*i)" } "." } ;

{ cis e^ } related-words

HELP: polar>
{ $values { "abs" "a non-negative real number" } { "arg" real } { "z" number } }
{ $description "Converts an absolute value and argument (polar form) to a complex number." } ;

HELP: [-1,1]?
{ $values { "x" number } { "?" boolean } }
{ $description "Tests if " { $snippet "x" } " is a real number between -1 and 1, inclusive." } ;

HELP: abs
{ $values { "x" number } { "y" "a non-negative real number" } }
{ $description "Computes the absolute value of a number." }
{ $see-also absq } ;

HELP: absq
{ $values { "x" number } { "y" "a non-negative real number" } }
{ $description "Computes the squared absolute value of a number. For complex numbers this is marginally more efficient than " { $link abs } "." } ;

HELP: ^
{ $values { "x" number } { "y" number } { "x^y" number } }
{ $description "Raises " { $snippet "x" } " to the power of " { $snippet "y" } ". If " { $snippet "y" } " is an integer the answer is computed exactly, otherwise a floating point approximation is used." }
{ $errors "Throws an error if " { $snippet "x" } " and " { $snippet "y" } " are both integer 0." } ;

HELP: nth-root
{ $values { "n" integer } { "x" number } { "y" number } }
{ $description "Calculates the nth root of a number, such that " { $snippet "y^n=x" } "." } ;

HELP: 10^
{ $values { "x" number } { "10^x" number } }
{ $description "Raises 10 to the power of " { $snippet "x" } ". If " { $snippet "x" } " is an integer the answer is computed exactly, otherwise a floating point approximation is used." } ;

HELP: divisor?
{ $values { "m" integer } { "n" integer } { "?" boolean } }
{ $description "Tests if " { $snippet "n" } " is a divisor of " { $snippet "m" } ". This is the same thing as asking if " { $snippet "m" } " is divisible by " { $snippet "n" } "." }
{ $notes "Returns t for both negative and positive divisors, as well as for trivial and non-trivial divisors." } ;

HELP: mod-inv
{ $values { "x" integer } { "n" integer } { "y" integer } }
{ $description "Outputs a positive integer " { $snippet "y" } " such that " { $snippet "x*y = 1 (mod n)" } "." }
{ $errors "Throws an error if " { $snippet "x" } " is not invertible modulo " { $snippet "n" } "." }
{ $examples
    { $example "USING: math.functions prettyprint ;" "173 1119 mod-inv ." "815" }
    { $example "USING: math prettyprint ;" "173 815 * 1119 mod ." "1" }
} ;

HELP: ^mod
{ $values { "x" real } { "y" real } { "n" real } { "z" real } }
{ $description "Outputs the result of computing " { $snippet "x^y mod n" } "." } ;

HELP: ~
{ $values { "x" real } { "y" real } { "epsilon" real } { "?" boolean } }
{ $description "Tests if " { $snippet "x" } " and " { $snippet "y" } " are approximately equal to each other. There are three possible comparison tests, chosen based on the sign of " { $snippet "epsilon" } ":"
    { $list
        { { $snippet "epsilon" } " is zero: exact comparison." }
        { { $snippet "epsilon" } " is positive: absolute distance test." }
        { { $snippet "epsilon" } " is negative: relative distance test." }
    }
} ;

HELP: truncate
{ $values { "x" real } { "y" "a whole real number" } }
{ $description "Outputs the number that results from subtracting the fractional component of " { $snippet "x" } "." }
{ $notes "The result is not necessarily an integer." } ;

HELP: floor
{ $values { "x" real } { "y" "a whole real number" } }
{ $description "Outputs the greatest whole number smaller than or equal to " { $snippet "x" } "." }
{ $notes "The result is not necessarily an integer." } ;

HELP: ceiling
{ $values { "x" real } { "y" "a whole real number" } }
{ $description "Outputs the least whole number greater than or equal to " { $snippet "x" } "." }
{ $notes "The result is not necessarily an integer." } ;

HELP: round
{ $values { "x" real } { "y" "a whole real number" } }
{ $description "Outputs the whole number closest to " { $snippet "x" } ", rounding out at half." }
{ $notes "The result is not necessarily an integer." }
{ $examples
    { $example "USING: math.functions prettyprint ;" "4.5 round ." "5.0" }
    { $example "USING: math.functions prettyprint ;" "4.4 round ." "4.0" }
} ;

HELP: round-to-even
{ $values { "x" real } { "y" "a whole real number" } }
{ $description "Outputs the whole number closest to " { $snippet "x" } ", rounding out at half, breaking ties towards even numbers. This is also known as banker's rounding or unbiased rounding." }
{ $notes "The result is not necessarily an integer." }
{ $examples
    { $example "USING: math.functions prettyprint ;" "0.5 round-to-even ." "0.0" }
    { $example "USING: math.functions prettyprint ;" "1.5 round-to-even ." "2.0" }
} ;

HELP: round-to-odd
{ $values { "x" real } { "y" "a whole real number" } }
{ $description "Outputs the whole number closest to " { $snippet "x" } ", rounding out at half, breaking ties towards odd numbers." }
{ $notes "The result is not necessarily an integer." }
{ $examples
    { $example "USING: math.functions prettyprint ;" "0.5 round-to-odd ." "1.0" }
    { $example "USING: math.functions prettyprint ;" "1.5 round-to-odd ." "1.0" }
} ;

HELP: round-to-decimal
{ $values { "x" real } { "n" integer } { "y" real } }
{ $description "Outputs the number closest to " { $snippet "x" } ", rounded to " { $snippet "n" } " decimal places." }
{ $notes "The result is not necessarily an integer." }
{ $examples
    { $example "USING: math.functions prettyprint ;" "1.23456 2 round-to-decimal ." "1.23" }
    { $example "USING: math.functions prettyprint ;" "12345.6789 -3 round-to-decimal ." "12000.0" }
} ;

HELP: round-to-step
{ $values { "x" real } { "step" real } { "y" real } }
{ $description "Outputs the number closest to " { $snippet "x" } ", rounded to a multiple of " { $snippet "step" } "." }
{ $notes "The result is not necessarily an integer." }
{ $examples
    { $example "USING: math.functions prettyprint ;" "1.23456 0.25 round-to-step ." "1.25" }
    { $example "USING: math.functions prettyprint ;" "12345.6789 100 round-to-step ." "12300.0" }
} ;

HELP: roots
{ $values { "x" number } { "t" integer } { "seq" sequence } }
{ $description "Outputs the " { $snippet "t" } " roots of a number " { $snippet "x" } "." }
{ $notes "The results are not necessarily real." } ;

HELP: sigmoid
{ $values { "x" number } { "y" number } }
{ $description "Outputs the sigmoid, an S-shaped \"logistic\" function, from 0 to 1, of the number " { $snippet "x" } "." } ;

HELP: signum
{ $values { "x" number } { "y" number } }
{ $description "Calculates the signum value. For a real number, " { $snippet "x" } ", this is its sign (-1, 0, or 1). For a complex number, " { $snippet "x" } ", this is the point on the unit circle of the complex plane that is nearest to " { $snippet "x" } "." } ;

HELP: copysign
{ $values { "x" number } { "y" number } { "x'" number } }
{ $description "Returns " { $snippet "x" } " with the sign of " { $snippet "y" } ", as a " { $link float } "." } ;

HELP: integer-sqrt
{ $values
    { "x" "a non-negative rational number" }
    { "n" integer }
}
{ $description "Outputs the largest integer that is less than or equal to the " { $link sqrt } " of " { $snippet "m" } "." }
{ $errors "Throws an error if " { $snippet "m" } " is negative." }
{ $examples
    { $example
        "USING: prettyprint math.functions ;"
        "15 integer-sqrt ."
        "3"
    }
} ;

HELP: integer-log10
{ $values
    { "x" "a positive rational number" }
    { "n" integer }
}
{ $description "Outputs the largest integer " { $snippet "n" } " such that " { $snippet "10^n" } " is less than or equal to " { $snippet "x" } "." }
{ $errors "Throws an error if " { $snippet "x" } " is zero or negative." }
{ $examples
    { $example
        "USING: prettyprint math.functions sequences ;"
        "{"
        "     5 99 100 101 100000000000000000000"
        "     100+1/2 1/100"
        "} [ integer-log10 ] map ."
        "{ 0 1 2 2 20 2 -2 }"
    }
} ;

HELP: integer-log2
{ $values
    { "x" "a positive rational number" }
    { "n" integer }
}
{ $description "Outputs the largest integer " { $snippet "n" } " such that " { $snippet "2^n" } " is less than or equal to " { $snippet "x" } "." }
{ $errors "Throws an error if " { $snippet "x" } " is zero or negative." } ;
