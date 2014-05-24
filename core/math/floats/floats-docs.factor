USING: help.markup help.syntax kernel math math.private ;
IN: math.floats

HELP: float
{ $class-description "The class of double-precision floating point numbers." } ;

HELP: >float
{ $values { "x" real } { "y" float } }
{ $description "Converts a real to a float. This is the identity on floats, and performs a floating point division on rationals." } ;

HELP: bits>double
{ $values { "n" "a 64-bit integer representing an IEEE 754 double-precision float" } { "x" float } }
{ $description "Creates a " { $link float } " object from a 64-bit binary representation. This word is usually used to reconstruct floats read from streams." } ;

{ bits>double bits>float double>bits float>bits } related-words

HELP: bits>float
{ $values { "n" "a 32-bit integer representing an IEEE 754 single-precision float" } { "x" float } }
{ $description "Creates a " { $link float } " object from a 32-bit binary representation. This word is usually used to reconstruct floats read from streams." } ;

HELP: double>bits
{ $values { "x" float } { "n" "a 64-bit integer representing an IEEE 754 double-precision float" } }
{ $description "Creates a 64-bit binary representation of a " { $link float } " object. This can be used in the process of writing a float to a stream." } ;

HELP: float>bits
{ $values { "x" float } { "n" "a 32-bit integer representing an IEEE 754 single-precision float" } }
{ $description "Creates a 32-bit binary representation of a " { $link float } " object. This can be used in the process of writing a float to a stream." } ;

! Unsafe primitives
HELP: float+
{ $values { "x" float } { "y" float } { "z" float } }
{ $description "Primitive version of " { $link + } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link + } " instead." } ;

HELP: float-
{ $values { "x" float } { "y" float } { "z" float } }
{ $description "Primitive version of " { $link - } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link - } " instead." } ;

HELP: float*
{ $values { "x" float } { "y" float } { "z" float } }
{ $description "Primitive version of " { $link * } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link * } " instead." } ;

HELP: float/f
{ $values { "x" float } { "y" float } { "z" float } }
{ $description "Primitive version of " { $link /f } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link /f } " instead." } ;

HELP: float<
{ $values { "x" float } { "y" float } { "?" boolean } }
{ $description "Primitive version of " { $link < } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link < } " instead." } ;

HELP: float<=
{ $values { "x" float } { "y" float } { "?" boolean } }
{ $description "Primitive version of " { $link <= } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link <= } " instead." } ;

HELP: float>
{ $values { "x" float } { "y" float } { "?" boolean } }
{ $description "Primitive version of " { $link > } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link > } " instead." } ;

HELP: float>=
{ $values { "x" float } { "y" float } { "?" boolean } }
{ $description "Primitive version of " { $link u>= } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link u>= } " instead." } ;

HELP: float-u<
{ $values { "x" float } { "y" float } { "?" boolean } }
{ $description "Primitive version of " { $link u< } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link u< } " instead." } ;

HELP: float-u<=
{ $values { "x" float } { "y" float } { "?" boolean } }
{ $description "Primitive version of " { $link u<= } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link u<= } " instead." } ;

HELP: float-u>
{ $values { "x" float } { "y" float } { "?" boolean } }
{ $description "Primitive version of " { $link u> } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link u> } " instead." } ;

HELP: float-u>=
{ $values { "x" float } { "y" float } { "?" boolean } }
{ $description "Primitive version of " { $link u>= } "." }
{ $warning "This word does not perform type checking, and passing objects of the wrong type can crash the runtime. User code should call the generic word " { $link u>= } " instead." } ;

ARTICLE: "math.floats.compare" "Floating point comparison operations"
"In mathematics, real numbers are linearly ordered; for any two numbers " { $snippet "a" } " and " { $snippet "b" } ", exactly one of the following is true:"
{ $code
    "a < b"
    "a = b"
    "a > b"
}
"With floating point values, there is a fourth possibility; " { $snippet "a" } " and " { $snippet "b" } " may be " { $emphasis "unordered" } ". This happens if one or both values are Not-a-Number values."
$nl
"All comparison operators, including " { $link number= } ", return " { $link f } " in the unordered case (and in particular, this means that a NaN is not equal to itself)."
$nl
"The " { $emphasis "ordered" } " comparison operators set floating point exception flags if the result of the comparison is unordered. The standard comparison operators (" { $link < } ", " { $link <= } ", " { $link > } ", " { $link >= } ") perform ordered comparisons."
$nl
"The " { $link number= } " operation performs an unordered comparison. The following set of operators also perform unordered comparisons:"
{ $subsections
    u<
    u<=
    u>
    u>=
}
"A word to check if two values are unordered with respect to each other:"
{ $subsections unordered? }
"To test for floating point exceptions, use the " { $vocab-link "math.floats.env" } " vocabulary."
$nl
"If neither input to a comparison operator is a floating point value, then " { $link u< } ", " { $link u<= } ", " { $link u> } " and " { $link u>= } " are equivalent to the ordered operators." ;

ARTICLE: "math.floats.bitwise" "Bitwise operations on floats"
"Floating point numbers are represented internally in IEEE 754 double-precision format. This internal representation can be accessed for advanced operations and input/output purposes."
{ $subsections
    float>bits
    double>bits
    bits>float
    bits>double
}
"Constructing floating point NaNs:"
{ $subsections <fp-nan> }
"Floating point numbers are discrete:"
{ $subsections
    prev-float
    next-float
}
"Introspection on floating point numbers:"
{ $subsections
    fp-special?
    fp-nan?
    fp-qnan?
    fp-snan?
    fp-infinity?
    fp-nan-payload
}
"Comparing two floating point numbers for bitwise equality:"
{ $subsections fp-bitwise= }
{ $see-also POSTPONE: NAN: } ;

ARTICLE: "floats" "Floats"
{ $subsections float }
"Rational numbers represent " { $emphasis "exact" } " quantities. On the other hand, a floating point number is an " { $emphasis "approximate" } " value. While rationals can grow to any required precision, floating point numbers have limited precision, and manipulating them is usually faster than manipulating ratios or bignums."
$nl
"Introducing a floating point number in a computation forces the result to be expressed in floating point."
{ $example "5/4 1/2 + ." "1+3/4" }
{ $example "5/4 0.5 + ." "1.75" }
"Floating point literal syntax is documented in " { $link "syntax-floats" } "."
$nl
"Integers and rationals can be converted to floats:"
{ $subsections >float }
"Two real numbers can be divided yielding a float result:"
{ $subsections
    /f
    "math.floats.bitwise"
    "math.floats.compare"
}
"The " { $vocab-link "math.floats.env" } " vocabulary provides functionality for controlling floating point exceptions, rounding modes, and denormal behavior." ;

ABOUT: "floats"
