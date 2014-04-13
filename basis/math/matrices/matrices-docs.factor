USING: help.markup help.syntax math sequences ;
IN: math.matrices

HELP: zero-matrix
{ $values { "m" integer } { "n" integer } { "matrix" sequence } }
{ $description "Creates a matrix of size " { $snippet "m x n" } ", filled with zeroes." } ;

HELP: diagonal-matrix
{ $values { "diagonal-seq" sequence } { "matrix" sequence } }
{ $description "Creates a matrix with the specified diagonal values." } ;

HELP: identity-matrix
{ $values { "n" integer } { "matrix" sequence } }
{ $description "Creates an identity matrix of size " { $snippet "n x n" } ", where the diagonal values are all ones." } ;

HELP: m.v
{ $values { "m" sequence } { "v" sequence } }
{ $description "Computes the dot product between a matrix and a vector." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 1 -1 2 } { 0 -3 1 } } { 2 1 0 } m.v ."
    "{ 1 -3 }"
  }
} ;

HELP: m.
{ $values { "m" sequence } }
{ $description "Computes the dot product between two matrices, i.e multiplies them." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 1 -1 2 } { 0 -3 1 } } { { 3 7 } { 9 12 } } m. ."
    "{ { -6 -5 } { -27 -36 } }"
  }
} ;

HELP: m+
{ $values { "m" sequence } }
{ $description "Adds the matrices component-wise." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 1 2 } { 3 4 } } { { 5 6 } { 7 8 } } m+ ."
    "{ { 6 8 } { 10 12 } }"
  }
} ;

HELP: m-
{ $values { "m" sequence } }
{ $description "Subtracts the matrices component-wise." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m- ."
    "{ { 2 7 } { 11 8 } }"
  }
} ;

HELP: kron
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Calculates the Kronecker product of two matrices." }
{ $examples
    { $example "USING: math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } { { 0 5 } { 6 7 } } kron ."
        "{ { 0 5 0 10 } { 6 7 12 14 } { 0 15 0 20 } { 18 21 24 28 } }" }
} ;

HELP: outer
{ $values { "u" sequence } { "v" sequence } { "m" sequence } }
{ $description "Computers the outer product of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples
    { $example "USING: math.matrices prettyprint ;"
        "{ 5 6 7 } { 1 2 3 } outer ."
        "{ { 5 10 15 } { 6 12 18 } { 7 14 21 } }" }
} ;
