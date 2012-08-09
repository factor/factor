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
