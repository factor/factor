! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: classes help.markup help.syntax kernel ;
IN: math.vectors.conversion

HELP: bad-vconvert
{ $values
    { "from-type" "a SIMD type" } { "to-type" "a SIMD type" }
}
{ $description "This error is thrown when " { $link vconvert } " is given two SIMD types it cannot directly convert." } ;

HELP: bad-vconvert-input
{ $values
    { "value" object } { "expected-type" class }
}
{ $description "This error is thrown when an input to " { $link vconvert } " does not match the expected " { $snippet "from-type" } "." } ;

{ bad-vconvert bad-vconvert-input } related-words

HELP: vconvert
{ $values
    { "from-type" "a SIMD type" } { "to-type" "a SIMD type" }
}
{ $description "Converts SIMD vectors of " { $snippet "from-type" } " to " { $snippet "to-type" } ". The number of inputs and outputs depends on the relationship of the two types:"
{ $list
{ "If " { $snippet "to-type" } " is a floating-point vector type with the same byte length and element count as the integer vector type " { $snippet "from-type" } " (for example, from " { $snippet "int-4" } " to " { $snippet "float-4" } " or from " { $snippet "longlong-2" } " to " { $snippet "double-2" } "), " { $snippet "vconvert" } " takes one vector of " { $snippet "from-type" } " and converts its elements to floating-point, outputting one vector of " { $snippet "to-type" } "." }
{ "Likewise, if " { $snippet "to-type" } " is an integer vector type with the same byte length and element count as the floating-point vector type " { $snippet "from-type" } ", " { $snippet "vconvert" } " takes one vector of " { $snippet "from-type" } " and truncates its elements to integers, outputting one vector of " { $snippet "to-type" } "." }
{ "If " { $snippet "to-type" } " is a vector type with the same byte length as and twice the element count of the vector type " { $snippet "from-type" } " (for example, from " { $snippet "int-4" } " to " { $snippet "ushort-8" } ", from " { $snippet "double-2" } " to " { $snippet "float-4" } ", or from " { $snippet "short-8" } " to " { $snippet "char-16" } "), " { $snippet "vconvert" } " takes two vectors of " { $snippet "from-type" } " and packs them into one vector of " { $snippet "to-type" } ", saturating values too large or small to be representable as elements of " { $snippet "to-type" } "." }
{ "If " { $snippet "to-type" } " is a vector type with the same byte length as and half the element count of the vector type " { $snippet "from-type" } " (for example, from " { $snippet "ushort-8" } " to " { $snippet "int-4" } ", from " { $snippet "float-4" } " to " { $snippet "double-2" } ", or from " { $snippet "char-16" } " to " { $snippet "short-8" } "), " { $snippet "vconvert" } " takes one vector of " { $snippet "from-type" } " and unpacks it into two vectors of " { $snippet "to-type" } "." }
}
{ $snippet "from-type" } " and " { $snippet "to-type" } " must adhere to the following restrictions; a " { $link bad-vconvert } " error will be thrown otherwise:"
{ $list
{ { $snippet "from-type" } " and " { $snippet "to-type" } " must have the same byte length. You cannot currently convert between 128- and 256-bit vector types." }
{ "For conversions between floating-point and integer vectors, " { $snippet "from-type" } " and " { $snippet "to-type" } " must have the same element length." }
{ "For packing conversions, " { $snippet "from-type" } " and " { $snippet "to-type" } " must be both floating-point or both integer types. Integer types can be packed from signed to unsigned or from unsigned to unsigned types. Unsigned to signed packing is invalid." }
{ "For unpacking conversions, " { $snippet "from-type" } " and " { $snippet "to-type" } " must be both floating-point or both integer types. Integer types can be unpacked from unsigned to signed or from unsigned to unsigned types. Signed to unsigned unpacking is invalid." }
}
}
{ $examples
"Conversion between integer and float vectors:"
{ $example "USING: alien.c-types math.vectors.conversion math.vectors.simd
prettyprint ;

int-4{ 0 1 2 3 } int-4 float-4 vconvert .
double-2{ 1.25 3.75 } double-2 longlong-2 vconvert ."
"float-4{ 0.0 1.0 2.0 3.0 }
longlong-2{ 1 3 }" }
"Packing conversions:"
{ $example "USING: alien.c-types math.vectors.conversion math.vectors.simd
prettyprint ;

int-4{ -8 70000 6000 50 } int-4{ 4 3 2 -1 } int-4 ushort-8 vconvert .
double-2{ 0.0 1.0e100 }
double-2{ -1.0e100 0.0 } double-2 float-4 vconvert ."
"ushort-8{ 0 65535 6000 50 4 3 2 0 }
float-4{ 0.0 1/0. -1/0. 0.0 }" }
"Unpacking conversions:"
{ $example "USING: alien.c-types kernel math.vectors.conversion
math.vectors.simd prettyprint ;

uchar-16{ 8 70 60 50 4 30 200 1 9 10 110 102 133 143 115 0 }
uchar-16 short-8 vconvert [ . ] bi@"
"short-8{ 8 70 60 50 4 30 200 1 }
short-8{ 9 10 110 102 133 143 115 0 }" }
} ;

ARTICLE: "math.vectors.conversion" "SIMD vector conversion"
"The " { $vocab-link "math.vectors.conversion" } " vocabulary provides facilities for converting SIMD vectors between floating-point and integer representations and between different-sized integer representations."
{ $subsections
    vconvert
} ;

ABOUT: "math.vectors.conversion"
