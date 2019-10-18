USING: help.markup help.syntax kernel math math.functions
sequences ;
IN: math.vectors

ARTICLE: "math-vectors-arithmetic" "Vector arithmetic"
"Vector/vector binary operations:"
{ $subsections
    v+
    v-
    v+-
    v*
    v/
    v^
}
"Vector unary operations:"
{ $subsections
    vneg
    vabs
    vsqrt
    vfloor
    vceiling
    vtruncate
}
"Vector/scalar and scalar/vector binary operations:"
{ $subsections
    vneg
    v*n
    n*v
    v/n
    n/v
    v+n
    n+v
    v-n
    n-v
    v^n
    n^v
}
"Saturated arithmetic (only on " { $link "specialized-arrays" } "):"
{ $subsections
    vs+
    vs-
    vs*
}
"Inner product and norm:"
{ $subsections
    v.
    norm
    norm-sq
    normalize
    p-norm
}
"Comparing entire vectors:"
{ $subsections
    distance
    v~
} ;

ARTICLE: "math-vectors-shuffle" "Vector shuffling, packing, and unpacking"
{ $notes
"These operations are primarily meant to be used with " { $vocab-link "math.vectors.simd" } " types. The software fallbacks for types not supported by hardware will not perform well."
}
$nl
{ $subsections
    vshuffle
    vbroadcast
    hlshift
    hrshift
    vmerge
    (vmerge)
}
"See the " { $vocab-link "math.vectors.conversion" } " vocabulary for packing, unpacking, and converting vectors." ;

ARTICLE: "math-vectors-logic" "Vector component- and bit-wise logic"
{ $notes
"See " { $link "math-vectors-simd-logic" } " for notes about using comparison and logical operations with SIMD vector types."
}
$nl
"Element comparisons:"
{ $subsections
    v<
    v<=
    v=
    v>=
    v>
    vunordered?
    vmax
    vmin
    vclamp
    vsupremum
    vinfimum
}
"Bitwise operations:"
{ $subsections
    vbitand
    vbitandn
    vbitor
    vbitxor
    vbitnot
    vlshift
    vrshift
}
"Element logical operations:"
{ $subsections
    vand
    vandn
    vor
    vxor
    vnot
    v?
    vif
}
"Entire vector tests:"
{ $subsections
    vall?
    vany?
    vnone?
}
"Element shuffling:"
{ $subsections vshuffle } ;

ARTICLE: "math-vectors-misc" "Miscellaneous vector functions"
{ $subsections
    trilerp
    bilerp
    vlerp
    vnlerp
    vbilerp
} ;

ARTICLE: "math-vectors-simd-logic" "Componentwise logic with SIMD vectors"
"Processor SIMD units supported by the " { $vocab-link "math.vectors.simd" } " vocabulary represent boolean values as bitmasks, where a true result's binary representation is all ones and a false representation is all zeroes. This is the format in which results from comparison words such as " { $link v= } " return their results and in which logic and test words such as " { $link vand } " and " { $link vall? } " take their inputs when working with SIMD types. For a float vector, false will manifest itself as " { $snippet "0.0" } " and true as a " { $link POSTPONE: NAN: } " literal with a string of on bits in its payload:"
{ $example
    "USING: math.vectors math.vectors.simd prettyprint ;"
    "float-4{ 1.0 2.0 3.0 0/0. } float-4{ 1.0 -2.0 3.0 0/0. } v= ."
    "float-4{ NAN: fffffe0000000 0.0 NAN: fffffe0000000 0.0 }"
}
"For an integer vector, false will manifest as " { $snippet "0" } " and true as " { $snippet "-1" } " (for signed vectors) or the largest representable value of the element type (for unsigned vectors):"
{ $example
"USING: math.vectors math.vectors.simd prettyprint alien.c-types ;

int-4{ 1 2 3 0 } int-4{ 1 -2 3 4 } v=
uchar-16{  0  1  2  3  4  5 6 7 8 9 10 11 12 13 14 15 }
uchar-16{ 15 14 13 12 11 10 9 8 7 6  5  4  3  2  1  0 } v<
[ . ] bi@"
"int-4{ -1 0 -1 0 }
uchar-16{ 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 }"
}
"This differs from Factor's native representation of boolean values, where " { $link f } " is false and every other value (including " { $snippet "0" } " and " { $snippet "0.0" } ") is true. To make it easy to construct literal SIMD masks, " { $link t } " and " { $link f } " are accepted inside SIMD literal syntax and expand to the proper true or false representation for the underlying type:"
{ $example
"USING: math.vectors math.vectors.simd prettyprint alien.c-types ;

int-4{ f f t f } ."
"int-4{ 0 0 -1 0 }" }
"However, extracting an element from a boolean SIMD vector with " { $link nth } " will not yield a valid Factor boolean. This is not generally a problem, since the results of vector comparisons are meant to be consumed by subsequent vector logical and test operations, which will accept SIMD values in the native boolean format."
$nl
"Providing a SIMD boolean vector with element values other than the proper true and false representations as an input to the vector logical or test operations is undefined. Do not count on operations such as " { $link vall? } " or " { $link v? } " using bitwise operations to construct their results."
$nl
"This applies to the output of the following element comparison words:"
{ $list
{ $link v< }
{ $link v<= }
{ $link v= }
{ $link v>= }
{ $link v> }
{ $link vunordered? }
}
"This likewise applies to the " { $snippet "mask" } " argument of " { $link v? } " and to the inputs and outputs of the following element logic words:"
{ $list
{ $link vand }
{ $link vandn }
{ $link vor }
{ $link vxor }
{ $link vnot }
}
"Finally, this applies to the inputs of these vector test words:"
{ $list
{ $link vall? }
{ $link vany? }
{ $link vnone? }
} ;

ARTICLE: "math-vectors" "Vector operations"
"Any Factor sequence can be used to represent a mathematical vector, however for best performance, the sequences defined by the " { $vocab-link "specialized-arrays" } " and " { $vocab-link "math.vectors.simd" } " vocabularies should be used."
{ $subsections
    "math-vectors-arithmetic"
    "math-vectors-logic"
    "math-vectors-shuffle"
    "math-vectors-misc"
} ;

ABOUT: "math-vectors"

HELP: vneg
{ $values { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Negates each element of " { $snippet "v" } "." } ;

HELP: vabs
{ $values { "v" "a sequence of numbers" } { "w" "a sequence of non-negative real numbers" } }
{ $description "Takes the absolute value of each element of " { $snippet "v" } "." } ;

HELP: vsqrt
{ $values { "v" "a sequence of non-negative real numbers" } { "w" "a sequence of non-negative real numbers" } }
{ $description "Takes the square root of each element of " { $snippet "v" } "." }
{ $warning "For performance reasons, this does not work with negative inputs, unlike " { $link sqrt } "." } ;

HELP: vfloor
{ $values { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Takes the " { $link floor } " of each element of " { $snippet "v" } "." } ;

HELP: vceiling
{ $values { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Takes the " { $link ceiling } " of each element of " { $snippet "v" } "." } ;

HELP: vtruncate
{ $values { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Truncates each element of " { $snippet "v" } "." } ;

HELP: n+v
{ $values { "n" number } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Adds " { $snippet "n" } " to each element of " { $snippet "v" } "." } ;

HELP: v+n
{ $values { "v" "a sequence of numbers" } { "n" number } { "w" "a sequence of numbers" } }
{ $description "Adds " { $snippet "n" } " to each element of " { $snippet "v" } "." } ;

HELP: n-v
{ $values { "n" number } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Subtracts each element of " { $snippet "v" } " from " { $snippet "n" } "." } ;

HELP: v-n
{ $values { "v" "a sequence of numbers" } { "n" number } { "w" "a sequence of numbers" } }
{ $description "Subtracts " { $snippet "n" } " from each element of " { $snippet "v" } "." } ;

HELP: n*v
{ $values { "n" number } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Multiplies each element of " { $snippet "v" } " by " { $snippet "n" } "." } ;

HELP: v*n
{ $values { "v" "a sequence of numbers" } { "n" number } { "w" "a sequence of numbers" } }
{ $description "Multiplies each element of " { $snippet "v" } " by " { $snippet "n" } "." } ;

HELP: n/v
{ $values { "n" number } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Divides " { $snippet "n" } " by each element of " { $snippet "v" } "." }
{ $errors "May throw an error if a division by zero occurs; see " { $link "division-by-zero" } "." } ;

HELP: v/n
{ $values { "v" "a sequence of numbers" } { "n" number } { "w" "a sequence of numbers" } }
{ $description "Divides each element of " { $snippet "v" } " by " { $snippet "n" } "." }
{ $errors "May throw an error if a division by zero occurs; see " { $link "division-by-zero" } "." } ;

HELP: n^v
{ $values { "n" number } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Raises " { $snippet "n" } " to the power of each element of " { $snippet "v" } "." } ;

HELP: v^n
{ $values { "v" "a sequence of numbers" } { "n" number } { "w" "a sequence of numbers" } }
{ $description "Raises each element of " { $snippet "u" } " to the power of " { $snippet "v" } "." } ;

HELP: v+
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Adds " { $snippet "u" } " and " { $snippet "v" } " component-wise." } ;

HELP: v-
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Subtracts " { $snippet "v" } " from " { $snippet "u" } " component-wise." } ;

HELP: v+-
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Adds and subtracts alternate elements of " { $snippet "v" } " and " { $snippet "u" } " component-wise. Elements at even indexes are subtracted, while elements at odd indexes are added." }
{ $examples
    { $example
        "USING: math.vectors prettyprint ;"
        "{ 1 2 3 } { 2 3 2 } v+- ."
        "{ -1 5 1 }"
    }
} ;

HELP: [v-]
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Subtracts " { $snippet "v" } " from " { $snippet "u" } " component-wise; any components which become negative are set to zero." } ;

HELP: v*
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Multiplies " { $snippet "u" } " and " { $snippet "v" } " component-wise." } ;

HELP: v/
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Divides " { $snippet "u" } " by " { $snippet "v" } " component-wise." }
{ $errors "May throw an error if a division by zero occurs; see " { $link "division-by-zero" } "." } ;

HELP: v^
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Raises " { $snippet "u" } " to the power of " { $snippet "v" } " component-wise." } ;

HELP: vmax
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Creates a sequence where each element is the maximum of the corresponding elements from " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples { $example "USING: math.vectors prettyprint ;" "{ 1 2 5 } { -7 6 3 } vmax ." "{ 1 6 5 }" } } ;

HELP: vmin
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Creates a sequence where each element is the minimum of the corresponding elements from " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples { $example "USING: math.vectors prettyprint ;" "{ 1 2 5 } { -7 6 3 } vmin ." "{ -7 2 3 }" } } ;

HELP: vclamp
{ $values { "v" "a sequence of real numbers" } { "min" "a sequence of real numbers" } { "max" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Creates a sequence where each element is clamped to the minimum and maximum elements of the " { $snippet "min" } " and " { $snippet "max" } " sequences." }
{ $examples
  { $example
    "USING: math.vectors prettyprint ;"
    "{ -10 30 120 } { 0 0 0 } { 100 100 100 } vclamp ."
    "{ 0 30 100 }"
  }
} ;

HELP: v.
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "x" "a real number" } }
{ $description "Computes the dot product of two vectors." } ;

HELP: h.
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "x" "a real number" } }
{ $description "Computes the Hermitian inner product of two vectors." } ;

HELP: vs+
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Adds " { $snippet "u" } " and " { $snippet "v" } " component-wise with saturation." }
{ $examples
    "With saturation:"
    { $example
        "USING: alien.c-types math.vectors prettyprint specialized-arrays ;"
        "SPECIALIZED-ARRAY: uchar"
        "uchar-array{ 100 200 150 } uchar-array{ 70 70 70 } vs+ ."
        "uchar-array{ 170 255 220 }"
    }
    "Without saturation:"
    { $example
        "USING: alien.c-types math.vectors prettyprint specialized-arrays ;"
        "SPECIALIZED-ARRAY: uchar"
        "uchar-array{ 100 200 150 } uchar-array{ 70 70 70 } v+ ."
        "uchar-array{ 170 14 220 }"
    }
} ;

HELP: vs-
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Subtracts " { $snippet "v" } " from " { $snippet "u" } " component-wise with saturation." } ;

HELP: vs*
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Multiplies " { $snippet "u" } " and " { $snippet "v" } " component-wise with saturation." } ;

HELP: vbitand
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Takes the bitwise and of " { $snippet "u" } " and " { $snippet "v" } " component-wise." }
{ $notes "Unlike " { $link bitand } ", this word may be used on a specialized array of floats or doubles, in which case the bitwise representation of the floating point numbers is operated upon." } ;

HELP: vbitandn
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Takes the bitwise and-not of " { $snippet "u" } " and " { $snippet "v" } " component-wise, where " { $snippet "x and-not y" } " is defined as " { $snippet "not(x) and y" } "." }
{ $notes "This word may be used on a specialized array of floats or doubles, in which case the bitwise representation of the floating point numbers is operated upon." } ;

HELP: vbitor
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Takes the bitwise or of " { $snippet "u" } " and " { $snippet "v" } " component-wise." }
{ $notes "Unlike " { $link bitor } ", this word may be used on a specialized array of floats or doubles, in which case the bitwise representation of the floating point numbers is operated upon." } ;

HELP: vbitxor
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Takes the bitwise exclusive or of " { $snippet "u" } " and " { $snippet "v" } " component-wise." }
{ $notes "Unlike " { $link bitxor } ", this word may be used on a specialized array of floats or doubles, in which case the bitwise representation of the floating point numbers is operated upon." } ;

HELP: vlshift
{ $values { "v" "a sequence of integers" } { "n" "a non-negative integer" } { "w" "a sequence of integers" } }
{ $description "Shifts each element of " { $snippet "v" } " to the left by " { $snippet "n" } " bits." }
{ $notes "Undefined behavior will result if " { $snippet "n" } " is negative." } ;

HELP: vrshift
{ $values { "v" "a sequence of integers" } { "n" "a non-negative integer" } { "w" "a sequence of integers" } }
{ $description "Shifts each element of " { $snippet "v" } " to the right by " { $snippet "n" } " bits." }
{ $notes "Undefined behavior will result if " { $snippet "n" } " is negative." } ;

HELP: hlshift
{ $values { "v" "a SIMD array" } { "n" "a non-negative integer" } { "w" "a SIMD array" } }
{ $description "Shifts the entire SIMD array to the left by " { $snippet "n" } " bytes, filling the vacated right-hand bits with zeroes. This word may only be used in a context where the compiler can statically infer that the input is a SIMD array." } ;

HELP: hrshift
{ $values { "v" "a SIMD array" } { "n" "a non-negative integer" } { "w" "a SIMD array" } }
{ $description "Shifts the entire SIMD array to the right by " { $snippet "n" } " bytes, filling the vacated left-hand bits with zeroes. This word may only be used in a context where the compiler can statically infer that the input is a SIMD array." } ;

HELP: vmerge
{ $values { "u" sequence } { "v" sequence } { "w" sequence } }
{ $description "Creates a new sequence of the same type as and twice the length of " { $snippet "u" } " and " { $snippet "v" } " by interleaving the elements of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples
{ $example "USING: kernel math.vectors prettyprint ;

{ \"A\" \"B\" \"C\" \"D\" } { \"1\" \"2\" \"3\" \"4\" } vmerge ."
"{ \"A\" \"1\" \"B\" \"2\" \"C\" \"3\" \"D\" \"4\" }"
} } ;

HELP: (vmerge)
{ $values { "u" sequence } { "v" sequence } { "h" sequence } { "t" sequence } }
{ $description "Creates two new sequences of the same type and size as " { $snippet "u" } " and " { $snippet "v" } " by interleaving the elements of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $notes "For hardware-supported SIMD vector types this word compiles to a single instruction per output value." }
{ $examples
{ $example "USING: kernel math.vectors prettyprint ;

{ \"A\" \"B\" \"C\" \"D\" } { \"1\" \"2\" \"3\" \"4\" } (vmerge) [ . ] bi@"
"{ \"A\" \"1\" \"B\" \"2\" }
{ \"C\" \"3\" \"D\" \"4\" }"
} } ;

HELP: (vmerge-head)
{ $values { "u" sequence } { "v" sequence } { "h" sequence } }
{ $description "Creates a new sequence of the same type and size as " { $snippet "u" } " and " { $snippet "v" } " by interleaving the elements from the first half of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $notes "For hardware-supported SIMD vector types this word compiles to a single instruction." }
{ $examples
{ $example "USING: kernel math.vectors prettyprint ;

{ \"A\" \"B\" \"C\" \"D\" } { \"1\" \"2\" \"3\" \"4\" } (vmerge-head) ."
"{ \"A\" \"1\" \"B\" \"2\" }"
} } ;

HELP: (vmerge-tail)
{ $values { "u" sequence } { "v" sequence } { "t" sequence } }
{ $description "Creates a new sequence of the same type and size as " { $snippet "u" } " and " { $snippet "v" } " by interleaving the elements from the tail half of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $notes "For hardware-supported SIMD vector types this word compiles to a single instruction." }
{ $examples
{ $example "USING: kernel math.vectors prettyprint ;

{ \"A\" \"B\" \"C\" \"D\" } { \"1\" \"2\" \"3\" \"4\" } (vmerge-tail) ."
"{ \"C\" \"3\" \"D\" \"4\" }"
} } ;

{ vmerge (vmerge) (vmerge-head) (vmerge-tail) } related-words

HELP: vbroadcast
{ $values { "u" "a SIMD array" } { "n" "a non-negative integer" } { "v" "a SIMD array" } }
{ $description "Outputs a new SIMD array of the same type as " { $snippet "u" } " where every element is equal to the " { $snippet "n" } "th element of " { $snippet "u" } "." }
{ $examples
    { $example
        "USING: alien.c-types math.vectors math.vectors.simd prettyprint ;"
        "int-4{ 69 42 911 13 } 2 vbroadcast ."
        "int-4{ 911 911 911 911 }"
    }
} ;

HELP: vshuffle
{ $values { "v" "a SIMD array" } { "perm" "an array of integers, or a byte-array" } { "w" "a SIMD array" } }
{ $description "Permutes the elements of a SIMD array. Duplicate entries are allowed in the permutation. The " { $snippet "perm" } " argument can have one of two forms:"
{ $list
{ "A literal array of integers of the same length as the vector. This will perform a static, elementwise shuffle." }
{ "A byte array or SIMD vector of the same byte length as the vector. This will perform a variable bytewise shuffle." }
} }
{ $examples
    { $example
        "USING: alien.c-types math.vectors math.vectors.simd prettyprint ;"
        "int-4{ 69 42 911 13 } { 1 3 2 3 } vshuffle ."
        "int-4{ 42 13 911 13 }"
    }
    { $example
        "USING: alien.c-types combinators math.vectors math.vectors.simd"
        "namespaces prettyprint prettyprint.config ;"
        "IN: scratchpad"
        ""
        ": endian-swap ( size -- vector )"
        "    {"
        "        { 1 [ uchar-16{ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 } ] }"
        "        { 2 [ uchar-16{ 1 0 3 2 5 4 7 6 9 8 11 10 13 12 15 14 } ] }"
        "        { 4 [ uchar-16{ 3 2 1 0 7 6 5 4 11 10 9 8 15 14 13 12 } ] }"
        "    } case ;"
        ""
        "int-4{ 0x11223344 0x11223344 0x11223344 0x11223344 }"
        "4 endian-swap vshuffle"
        "16 number-base [ . ] with-variable"
        "int-4{ 0x44332211 0x44332211 0x44332211 0x44332211 }"
    }
} ;

HELP: norm-sq
{ $values { "v" "a sequence of numbers" } { "x" "a non-negative real number" } }
{ $description "Computes the squared length of a mathematical vector." } ;

HELP: norm
{ $values { "v" "a sequence of numbers" } { "x" "a non-negative real number" } }
{ $description "Computes the length of a mathematical vector." } ;

HELP: p-norm
{ $values { "v" "a sequence of numbers" } { "p" "a positive real number" } { "x" "a non-negative real number" } }
{ $description "Computes the length of a mathematical vector in " { $snippet "L^p" } " space." } ;

HELP: normalize
{ $values { "v" "a sequence of numbers, not all zero" } { "w" "a sequence of numbers" } }
{ $description "Outputs a vector with the same direction as " { $snippet "v" } " but length 1." } ;

HELP: distance
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "x" "a non-negative real number" } }
{ $description "Outputs the Euclidean distance between two vectors." } ;

HELP: set-axis
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "axis" "a sequence of 0/1" } { "w" "a sequence of numbers" } }
{ $description "Using " { $snippet "w" } " as a template, creates a new sequence containing corresponding elements from " { $snippet "u" } " in place of 0, and corresponding elements from " { $snippet "v" } " in place of 1." }
{ $examples { $example "USING: math.vectors prettyprint ;" "{ 1 2 3 } { 4 5 6 } { 0 1 0 } set-axis ." "{ 1 5 3 }" } } ;

HELP: v<
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when the former is less than the latter or " { $link f } " otherwise." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean results when using SIMD types." } ;

HELP: v<=
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when the former is less than or equal to the latter or " { $link f } " otherwise." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean results when using SIMD types." } ;

HELP: v=
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when they are equal or " { $link f } " otherwise." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean results when using SIMD types." } ;

HELP: v>
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when the former is greater than the latter or " { $link f } " otherwise." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean results when using SIMD types." } ;

HELP: v>=
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when the former is greater than or equal to the latter or " { $link f } " otherwise." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean results when using SIMD types." } ;

HELP: vunordered?
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when either value is Not-a-Number or " { $link f } " otherwise." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean results when using SIMD types." } ;

HELP: vand
{ $values { "u" "a sequence of booleans" } { "v" "a sequence of booleans" } { "w" "a sequence of booleans" } }
{ $description "Takes the logical AND of each corresponding element of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs and results when using SIMD types." } ;

HELP: vandn
{ $values { "u" "a sequence of booleans" } { "v" "a sequence of booleans" } { "w" "a sequence of booleans" } }
{ $description "Takes the logical AND-NOT of each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", where " { $snippet "x AND-NOT y" } " is defined as " { $snippet "NOT(x) AND y" } "." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs and results when using SIMD types." } ;

HELP: vor
{ $values { "u" "a sequence of booleans" } { "v" "a sequence of booleans" } { "w" "a sequence of booleans" } }
{ $description "Takes the logical OR of each corresponding element of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs and results when using SIMD types." } ;

HELP: vxor
{ $values { "u" "a sequence of booleans" } { "v" "a sequence of booleans" } { "w" "a sequence of booleans" } }
{ $description "Takes the logical XOR of each corresponding element of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs and results when using SIMD types." } ;

HELP: vnot
{ $values { "v" "a sequence of booleans" } { "w" "a sequence of booleans" } }
{ $description "Takes the logical NOT of each element of " { $snippet "v" } "." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs and results when using SIMD types." } ;

HELP: v?
{ $values { "mask" "a sequence of booleans" } { "true" "a sequence of numbers" } { "false" "a sequence of numbers" } { "result" "a sequence of numbers" } }
{ $description "Creates a new sequence by selecting elements from the " { $snippet "true" } " and " { $snippet "false" } " sequences based on whether the corresponding bits of the " { $snippet "mask" } " sequence are set or not." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs and results when using SIMD types." } ;

HELP: vif
{ $values { "mask" "a sequence of booleans" } { "true-quot" { $quotation ( -- vector ) } } { "false-quot" { $quotation ( -- vector ) } } { "result" sequence } }
{ $description "If all of the elements of " { $snippet "mask" } " are true, " { $snippet "true-quot" } " is called and its output value returned. If all of the elements of " { $snippet "mask" } " are false, " { $snippet "false-quot" } " is called and its output value returned. Otherwise, both quotations are called and " { $snippet "mask" } " is used to select elements from each output as with " { $link v? } "." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs and results when using SIMD types."
$nl
"For most conditional SIMD code, unless a case is exceptionally expensive to compute, it is usually most efficient to just compute all cases and blend them with " { $link v? } " instead of using " { $snippet "vif" } "." } ;

{ v? vif } related-words

HELP: vany?
{ $values { "v" "a sequence of booleans" } { "?" boolean } }
{ $description "Returns true if any element of " { $snippet "v" } " is true." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs when using SIMD types." } ;

HELP: vall?
{ $values { "v" "a sequence of booleans" } { "?" boolean } }
{ $description "Returns true if every element of " { $snippet "v" } " is true." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs when using SIMD types." } ;

HELP: vnone?
{ $values { "v" "a sequence of booleans" } { "?" boolean } }
{ $description "Returns true if every element of " { $snippet "v" } " is false." }
{ $notes "See " { $link "math-vectors-simd-logic" } " for notes on dealing with vector boolean inputs when using SIMD types." } ;

{ 2map v+ v- v* v/ } related-words

{ 2reduce v. } related-words

{ vs+ vs- vs* } related-words

{ v< v<= v= v> v>= vunordered? vand vor vxor vnot vany? vall? vnone? v? } related-words

{ vbitand vbitandn vbitor vbitxor vbitnot } related-words
