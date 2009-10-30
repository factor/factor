USING: help.markup help.syntax kernel math math.order
sequences quotations math.functions.private ;
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
}
"Inexact comparison:"
{ $subsections ~ }
"Numbers implement the " { $link "math.order" } ", therefore operations such as " { $link min } " and " { $link max } " can be used with numbers." ;

ARTICLE: "power-functions" "Powers and logarithms"
"Squares:"
{ $subsections sq sqrt }
"Exponential and natural logarithm:"
{ $subsections exp cis log }
"Other logarithms:"
{ $subsections log1+ log10 }
"Raising a number to a power:"
{ $subsections ^ 10^ }
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

HELP: rect>
{ $values { "x" real } { "y" real } { "z" number } }
{ $description "Creates a complex number from real and imaginary components. If " { $snippet "z" } " is an integer zero, this will simply output " { $snippet "x" } "." } ;

HELP: >rect
{ $values { "z" number } { "x" real } { "y" real } }
{ $description "Extracts the real and imaginary components of a complex number." } ;

HELP: align
{ $values { "m" integer } { "w" "a power of 2" } { "n" "an integer multiple of " { $snippet "w" } } }
{ $description "Outputs the least multiple of " { $snippet "w" } " greater than " { $snippet "m" } "." }
{ $notes "This word will give an incorrect result if " { $snippet "w" } " is not a power of 2." } ;

HELP: exp
{ $values { "x" number } { "y" number } }
{ $description "Exponential function, " { $snippet "y=e^x" } "." } ;

HELP: log
{ $values { "x" number } { "y" number } }
{ $description "Natural logarithm function. Outputs negative infinity if " { $snippet "x" } " is 0." } ;

HELP: log1+
{ $values { "x" number } { "y" number } }
{ $description "Takes the natural logarithm of " { $snippet "1 + x" } ". Outputs negative infinity if " { $snippet "1 + x" } " is zero. This word may be more accurate than " { $snippet "1 + log" } " for very small values of " { $snippet "x" } "." } ;

HELP: log10
{ $values { "x" number } { "y" number } }
{ $description "Logarithm function base 10. Outputs negative infinity if " { $snippet "x" } " is 0." } ;

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
{ $description "Computes a point on the unit circle using Euler's formula for " { $snippet "exp(arg*i)" } "." } ;

{ cis exp } related-words

HELP: polar>
{ $values { "abs" "a non-negative real number" } { "arg" real } { "z" number } }
{ $description "Converts an absolute value and argument (polar form) to a complex number." } ;

HELP: [-1,1]?
{ $values { "x" number } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "x" } " is a real number between -1 and 1, inclusive." } ;

HELP: abs
{ $values { "x" number } { "y" "a non-negative real number" } }
{ $description "Computes the absolute value of a complex number." } ;

HELP: absq
{ $values { "x" number } { "y" "a non-negative real number" } }
{ $description "Computes the squared absolute value of a complex number. This is marginally more efficient than " { $link abs } "." } ;

HELP: ^
{ $values { "x" number } { "y" number } { "z" number } }
{ $description "Raises " { $snippet "x" } " to the power of " { $snippet "y" } ". If " { $snippet "y" } " is an integer the answer is computed exactly, otherwise a floating point approximation is used." }
{ $errors "Throws an error if " { $snippet "x" } " and " { $snippet "y" } " are both integer 0." } ;

HELP: nth-root
{ $values { "n" integer } { "x" number } { "y" number } }
{ $description "Calculates the nth root of a number, such that " { $snippet "y^n=x" } "." } ;

HELP: 10^
{ $values { "x" number } { "y" number } }
{ $description "Raises " { $snippet "x" } " to the power of 10. If " { $snippet "x" } " is an integer the answer is computed exactly, otherwise a floating point approximation is used." } ;

HELP: gcd
{ $values { "x" integer } { "y" integer } { "a" integer } { "d" integer } }
{ $description "Computes the positive greatest common divisor " { $snippet "d" } " of " { $snippet "x" } " and " { $snippet "y" } ", and another value " { $snippet "a" } " satisfying:" { $code "a*y = d mod x" } }
{ $notes "If " { $snippet "d" } " is 1, then " { $snippet "a" } " is the inverse of " { $snippet "y" } " modulo " { $snippet "x" } "." } ;

HELP: divisor?
{ $values { "m" integer } { "n" integer } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "n" } " is a divisor of " { $snippet "m" } ". This is the same thing as asking if " { $snippet "m" } " is divisible by " { $snippet "n" } "." }
{ $notes "Returns t for both negative and positive divisors, as well as for trivial and non-trivial divisors." } ;

HELP: mod-inv
{ $values { "x" integer } { "n" integer } { "y" integer } }
{ $description "Outputs an integer " { $snippet "y" } " such that " { $snippet "xy = 1 (mod n)" } "." }
{ $errors "Throws an error if " { $snippet "n" } " is not invertible modulo " { $snippet "n" } "." }
{ $examples
    { $example "USING: math.functions prettyprint ;" "173 1119 mod-inv ." "815" }
    { $example "USING: math prettyprint ;" "173 815 * 1119 mod ." "1" }
} ;

HELP: ~
{ $values { "x" real } { "y" real } { "epsilon" real } { "?" "a boolean" } }
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
{ $description "Outputs the whole number closest to " { $snippet "x" } "." }
{ $notes "The result is not necessarily an integer." } ;
