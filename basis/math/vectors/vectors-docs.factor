USING: help.markup help.syntax math math.functions sequences ;
IN: math.vectors

ARTICLE: "math-vectors" "Vector arithmetic"
"Any Factor sequence can be used to represent a mathematical vector, however for best performance, the sequences defined by the " { $vocab-link "specialized-arrays" } " and " { $vocab-link "math.vectors.simd" } " vocabularies should be used."
$nl
"Acting on vectors by a scalar:"
{ $subsection vneg }
{ $subsection v*n }
{ $subsection n*v }
{ $subsection v/n }
{ $subsection n/v }
{ $subsection v+n }
{ $subsection n+v }
{ $subsection v-n }
{ $subsection n-v }
"Vector unary operations:"
{ $subsection vneg }
{ $subsection vabs }
{ $subsection vsqrt }
{ $subsection vfloor }
{ $subsection vceiling }
{ $subsection vtruncate }
"Vector/vector binary operations:"
{ $subsection v+ }
{ $subsection v- }
{ $subsection v+- }
{ $subsection v* }
{ $subsection v/ }
"Saturated arithmetic (only on " { $link "specialized-arrays" } "):"
{ $subsection vs+ }
{ $subsection vs- }
{ $subsection vs* }
"Componentwise vector operations:"
{ $subsection v< }
{ $subsection v<= }
{ $subsection v= }
{ $subsection v>= }
{ $subsection v> }
{ $subsection vunordered? }
{ $subsection vmax }
{ $subsection vmin }
"Bitwise operations:"
{ $subsection vbitand }
{ $subsection vbitandn }
{ $subsection vbitor }
{ $subsection vbitxor }
{ $subsection vlshift }
{ $subsection vrshift }
"Componentwise logical operations:"
{ $subsection vand }
{ $subsection vor }
{ $subsection vxor }
{ $subsection vmask }
{ $subsection v? }
"Shuffling:"
{ $subsection vshuffle }
"Inner product and norm:"
{ $subsection v. }
{ $subsection norm }
{ $subsection norm-sq }
{ $subsection normalize }
"Comparing entire vectors:"
{ $subsection distance }
{ $subsection v~ }
"Other functions:"
{ $subsection vsupremum }
{ $subsection vinfimum }
{ $subsection trilerp }
{ $subsection bilerp }
{ $subsection vlerp }
{ $subsection vnlerp }
{ $subsection vbilerp } ;

ABOUT: "math-vectors"

HELP: vneg
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } }
{ $description "Negates each element of " { $snippet "u" } "." } ;

HELP: vabs
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of non-negative real numbers" } }
{ $description "Takes the absolute value of each element of " { $snippet "u" } "." } ;

HELP: vsqrt
{ $values { "u" "a sequence of non-negative real numbers" } { "v" "a sequence of non-negative real numbers" } }
{ $description "Takes the square root of each element of " { $snippet "u" } "." }
{ $warning "For performance reasons, this does not work with negative inputs, unlike " { $link sqrt } "." } ;

HELP: vfloor
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } }
{ $description "Takes the " { $link floor } " of each element of " { $snippet "u" } "." } ;

HELP: vceiling
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } }
{ $description "Takes the " { $link ceiling } " of each element of " { $snippet "u" } "." } ;

HELP: vtruncate
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } }
{ $description "Truncates each element of " { $snippet "u" } "." } ;

HELP: n+v
{ $values { "n" "a number" } { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } }
{ $description "Adds " { $snippet "n" } " to each element of " { $snippet "u" } "." } ;

HELP: v+n
{ $values { "u" "a sequence of numbers" } { "n" "a number" } { "v" "a sequence of numbers" } }
{ $description "Adds " { $snippet "n" } " to each element of " { $snippet "u" } "." } ;

HELP: n-v
{ $values { "n" "a number" } { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } }
{ $description "Subtracts each element of " { $snippet "u" } " from " { $snippet "n" } "." } ;

HELP: v-n
{ $values { "u" "a sequence of numbers" } { "n" "a number" } { "v" "a sequence of numbers" } }
{ $description "Subtracts " { $snippet "n" } " from each element of " { $snippet "u" } "." } ;

HELP: n*v
{ $values { "n" "a number" } { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } }
{ $description "Multiplies each element of " { $snippet "u" } " by " { $snippet "n" } "." } ;

HELP: v*n
{ $values { "u" "a sequence of numbers" } { "n" "a number" } { "v" "a sequence of numbers" } }
{ $description "Multiplies each element of " { $snippet "u" } " by " { $snippet "n" } "." } ;

HELP: n/v
{ $values { "n" "a number" } { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } }
{ $description "Divides " { $snippet "n" } " by each element of " { $snippet "u" } "." }
{ $errors "May throw an error if a division by zero occurs; see " { $link "division-by-zero" } "." } ;

HELP: v/n
{ $values { "u" "a sequence of numbers" } { "n" "a number" } { "v" "a sequence of numbers" } }
{ $description "Divides each element of " { $snippet "u" } " by " { $snippet "n" } "." }
{ $errors "May throw an error if a division by zero occurs; see " { $link "division-by-zero" } "." } ;

HELP: v+
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Adds " { $snippet "u" } " and " { $snippet "v" } " component-wise." } ;

HELP: v-
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Subtracts " { $snippet "v" } " from " { $snippet "u" } " component-wise." } ;

HELP: v+-
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Adds and subtracts alternate elements of " { $snippet "v" } " and " { $snippet "u" } " component-wise." }
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

HELP: vmax
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Creates a sequence where each element is the maximum of the corresponding elements from " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples { $example "USING: math.vectors prettyprint ;" "{ 1 2 5 } { -7 6 3 } vmax ." "{ 1 6 5 }" } } ;

HELP: vmin
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Creates a sequence where each element is the minimum of the corresponding elements from " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples { $example "USING: math.vectors prettyprint ;" "{ 1 2 5 } { -7 6 3 } vmin ." "{ -7 2 3 }" } } ;

HELP: v.
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "x" "a real number" } }
{ $description "Computes the dot product of two vectors." } ;

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
{ $values { "u" "a sequence of integers" } { "n" "a non-negative integer" } { "w" "a sequence of integers" } }
{ $description "Shifts each element of " { $snippet "u" } " to the left by " { $snippet "n" } " bits." }
{ $notes "Undefined behavior will result if " { $snippet "n" } " is negative." } ;

HELP: vrshift
{ $values { "u" "a sequence of integers" } { "n" "a non-negative integer" } { "w" "a sequence of integers" } }
{ $description "Shifts each element of " { $snippet "u" } " to the right by " { $snippet "n" } " bits." }
{ $notes "Undefined behavior will result if " { $snippet "n" } " is negative." } ;

HELP: hlshift
{ $values { "u" "a SIMD array" } { "n" "a non-negative integer" } { "w" "a SIMD array" } }
{ $description "Shifts the entire SIMD array to the left by " { $snippet "n" } " bytes. This word may only be used in a context where the compiler can statically infer that the input is a SIMD array." } ;

HELP: hrshift
{ $values { "u" "a SIMD array" } { "n" "a non-negative integer" } { "w" "a SIMD array" } }
{ $description "Shifts the entire SIMD array to the right by " { $snippet "n" } " bytes. This word may only be used in a context where the compiler can statically infer that the input is a SIMD array." } ;

HELP: vshuffle
{ $values { "u" "a SIMD array" } { "perm" "an array of integers" } { "v" "a SIMD array" } }
{ $description "Permutes the elements of a SIMD array. Duplicate entries are allowed in the permutation." }
{ $examples
    { $example
        "USING: alien.c-types math.vectors math.vectors.simd" "prettyprint ;"
        "SIMD: int"
        "int-4{ 69 42 911 13 } { 1 3 2 3 } vshuffle ."
        "int-4{ 42 13 911 13 }"
    }
} ;

HELP: norm-sq
{ $values { "v" "a sequence of numbers" } { "x" "a non-negative real number" } }
{ $description "Computes the squared length of a mathematical vector." } ;

HELP: norm
{ $values { "v" "a sequence of numbers" } { "x" "a non-negative real number" } }
{ $description "Computes the length of a mathematical vector." } ;

HELP: normalize
{ $values { "u" "a sequence of numbers, not all zero" } { "v" "a sequence of numbers" } }
{ $description "Outputs a vector with the same direction as " { $snippet "u" } " but length 1." } ;

HELP: distance
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "x" "a non-negative real number" } }
{ $description "Outputs the Euclidean distance between two vectors." } ;

HELP: set-axis
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "axis" "a sequence of 0/1" } { "w" "a sequence of numbers" } }
{ $description "Using " { $snippet "w" } " as a template, creates a new sequence containing corresponding elements from " { $snippet "u" } " in place of 0, and corresponding elements from " { $snippet "v" } " in place of 1." }
{ $examples { $example "USING: math.vectors prettyprint ;" "{ 1 2 3 } { 4 5 6 } { 0 1 0 } set-axis ." "{ 1 5 3 }" } } ;

HELP: v<
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when the former is less than the latter or " { $link f } " otherwise." } ;

HELP: v<=
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when the former is less than or equal to the latter or " { $link f } " otherwise." } ;

HELP: v=
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when they are equal or " { $link f } " otherwise." } ;

HELP: v>
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when the former is greater than the latter or " { $link f } " otherwise." } ;

HELP: v>=
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when the former is greater than or equal to the latter or " { $link f } " otherwise." } ;

HELP: vunordered?
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of booleans" } }
{ $description "Compares each corresponding element of " { $snippet "u" } " and " { $snippet "v" } ", returning " { $link t } " in the result vector when either value is Not-a-Number or " { $link f } " otherwise." } ;

HELP: vand
{ $values { "u" "a sequence of booleans" } { "v" "a sequence of booleans" } { "w" "a sequence of booleans" } }
{ $description "Takes the logical AND of each corresponding element of " { $snippet "u" } " and " { $snippet "v" } "." } ;

HELP: vor
{ $values { "u" "a sequence of booleans" } { "v" "a sequence of booleans" } { "w" "a sequence of booleans" } }
{ $description "Takes the logical OR of each corresponding element of " { $snippet "u" } " and " { $snippet "v" } "." } ;

HELP: vxor
{ $values { "u" "a sequence of booleans" } { "v" "a sequence of booleans" } { "w" "a sequence of booleans" } }
{ $description "Takes the logical XOR of each corresponding element of " { $snippet "u" } " and " { $snippet "v" } "." } ;

HELP: vnot
{ $values { "u" "a sequence of booleans" } { "w" "a sequence of booleans" } }
{ $description "Takes the logical NOT of each element of " { $snippet "u" } "." } ;

HELP: vmask
{ $values { "u" "a sequence of numbers" } { "?" "a sequence of booleans" } { "u'" "a sequence of numbers" } }
{ $description "Returns a copy of " { $snippet "u" } " with the elements for which the corresponding element of " { $snippet "?" } " is false replaced by zero." } ;

HELP: v?
{ $values { "?" "a sequence of booleans" } { "true" "a sequence of numbers" } { "false" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Creates a new sequence by selecting elements from the " { $snippet "true" } " and " { $snippet "false" } " sequences based on whether the corresponding element of the " { $snippet "?" } " sequence is true or false." } ;

{ 2map v+ v- v* v/ } related-words

{ 2reduce v. } related-words

{ vs+ vs- vs* } related-words

{ v< v<= v= v> v>= vunordered? vand vor vxor vnot vmask v? } related-words

{ vbitand vbitandn vbitor vbitxor vbitnot } related-words
