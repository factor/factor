USING: help.markup help.syntax math sequences ;
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
"Combining two vectors to form another vector with " { $link 2map } ":"
{ $subsection v+ }
{ $subsection v- }
{ $subsection v* }
{ $subsection v/ }
{ $subsection vmax }
{ $subsection vmin }
"Inner product and norm:"
{ $subsection v. }
{ $subsection norm }
{ $subsection norm-sq }
{ $subsection normalize } ;

ABOUT: "math-vectors"

HELP: vneg
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } }
{ $description "Negates each element of " { $snippet "u" } "." } ;

HELP: n*v
{ $values { "n" "a number" } { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } }
{ $description "Multiplies each element of " { $snippet "u" } " by " { $snippet "n" } "." } ;

HELP: v*n
{ $values { "u" "a sequence of numbers" } { "n" "a number" } { "v" "a sequence of numbers" } }
{ $description "Multiplies each element of " { $snippet "u" } " by " { $snippet "n" } "." } ;

HELP: n/v
{ $values { "n" "a number" } { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } }
{ $description "Divides " { $snippet "n" } " by each element of " { $snippet "u" } "." } ;

HELP: v/n
{ $values { "u" "a sequence of numbers" } { "n" "a number" } { "v" "a sequence of numbers" } }
{ $description "Divides each element of " { $snippet "u" } " by " { $snippet "n" } "." } ;

HELP: v+
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Adds " { $snippet "u" } " and " { $snippet "v" } " component-wise." } ;

HELP: v-
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Subtracts " { $snippet "v" } " from " { $snippet "u" } " component-wise." } ;

HELP: [v-]
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Subtracts " { $snippet "v" } " from " { $snippet "u" } " component-wise; any components which become negative are set to zero." } ;

HELP: v*
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Multiplies " { $snippet "u" } " and " { $snippet "v" } " component-wise." } ;

HELP: v/
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "w" "a sequence of numbers" } }
{ $description "Divides " { $snippet "u" } " by " { $snippet "v" } " component-wise." }
{ $errors "Throws an error if an integer division by zero occurs." } ;

HELP: vmax
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Creates a sequence where each element is the maximum of the corresponding elements from " { $snippet "u" } " andd " { $snippet "v" } "." }
{ $examples { $example "USING: math.vectors prettyprint ;" "{ 1 2 5 } { -7 6 3 } vmax ." "{ 1 6 5 }" } } ;

HELP: vmin
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "w" "a sequence of real numbers" } }
{ $description "Creates a sequence where each element is the minimum of the corresponding elements from " { $snippet "u" } " andd " { $snippet "v" } "." }
{ $examples { $example "USING: math.vectors prettyprint ;" "{ 1 2 5 } { -7 6 3 } vmin ." "{ -7 2 3 }" } } ;

HELP: v.
{ $values { "u" "a sequence of real numbers" } { "v" "a sequence of real numbers" } { "x" "a real number" } }
{ $description "Computes the real-valued dot product." }
{ $notes
    "This word can also take complex number sequences as input, however mathematically it will compute the wrong result. The complex-valued dot product is defined differently:"
    { $snippet "0 [ conjugate * + ] 2reduce" }
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

HELP: set-axis
{ $values { "u" "a sequence of numbers" } { "v" "a sequence of numbers" } { "axis" "a sequence of 0/1" } { "w" "a sequence of numbers" } }
{ $description "Using " { $snippet "w" } " as a template, creates a new sequence containing corresponding elements from " { $snippet "u" } " in place of 0, and corresponding elements from " { $snippet "v" } " in place of 1." }
{ $examples { $example "USING: math.vectors prettyprint ;" "{ 1 2 3 } { 4 5 6 } { 0 1 0 } set-axis ." "{ 1 5 3 }" } } ;

{ 2map v+ v- v* v/ } related-words

{ 2reduce v. } related-words
