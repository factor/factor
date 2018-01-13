! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, Cat Stevens.
USING: help.markup help.syntax kernel math sequences urls ;
IN: math.matrices

ABOUT: "math.matrices"

ARTICLE: "math.matrices" "Working with matrix data"
"The " { $vocab-link "math.matrices" } " vocabulary implements many ways of working with 2-dimensional sequences, known as matrices. Operations on numeric vectors are implemented in " { $vocab-link "math.vectors" } ", upon which this vocabulary relies."
$nl
"Instead of a separate matrix " { $link tuple } " to be instantiated, words in this vocabulary operate on 2-dimensional sequences."
$nl
"Creating simple matrices:"
{ $subsections
    <matrix>
    make-matrix
    zero-matrix
    diagonal-matrix
    identity-matrix
    eye
    square-rows
    square-cols
    make-matrix-with-indices
    make-upper-matrix
    make-lower-matrix
    cartesian-square-indices
}

"Special kinds of matrices:"
{ $subsections
    box-matrix
    hankel-matrix
    hilbert-matrix
    toeplitz-matrix
    vandermonde-matrix
}

"Domain-specific transformation matrices:"
{ $subsections
    frustum-matrix4
    ortho-matrix4
    rotation-matrix3
    rotation-matrix4
    scale-matrix3
    scale-matrix4
    skew-matrix4
    translation-matrix4
}

"By-element mathematical operations of a matrix and a scalar:"
{ $subsections mneg n+m m+n n-m m-n n*m m*n n/m m/n m^n }

"By-element mathematical operations of two matricess:"
{ $subsections m+ m- m* m/ m~ }

"Dot product (multiplication) of vectors and matrices:"
{ $subsections v.m m.v m. }

"Transformations on matrices:"
{ $subsections
    cartesian-matrix-map
    cartesian-matrix-column-map
    column-map
    cross
    normal
    proj
    perp
    angle-between
    gram-schmidt
    gram-schmidt-normal
    stitch
    kronecker
    outer
    upper-matrix-indices
    lower-matrix-indices
}

"Covariance in matrices:"
{ $subsections
    cov-matrix
    cov-matrix-ddof
    sample-cov-matrix
}

"Accesing parts of a matrix:"
{ $subsections
  row
  rows
  col
  cols
}

"Mutating matrices in place:"
{ $subsections
  set-index
  set-indices
  matrix-map
}

"Attributes of a matrix:"
{ $subsections
    dim
    mmin
    mmax
    mnorm
    null-matrix?
    well-formed-matrix?
    square-matrix?
} ;

HELP: zero-matrix
{ $values { "m" integer } { "n" integer } { "matrix" sequence } }
{ $description "Creates a matrix of size " { $snippet "m x n" } ", filled with zeroes." } ;

HELP: diagonal-matrix
{ $values { "diagonal-seq" sequence } { "matrix" sequence } }
{ $description "Creates a matrix with the specified diagonal values." } ;

HELP: identity-matrix
{ $values { "n" integer } { "matrix" sequence } }
{ $description "Creates an " { $url URL" http://enwp.org/Identity_matrix" "identity matrix" } " of size " { $snippet "n x n" } ", where the diagonal values are all ones." } ;

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
{ $description "Adds the matrices element-wise." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 1 2 } { 3 4 } } { { 5 6 } { 7 8 } } m+ ."
    "{ { 6 8 } { 10 12 } }"
  }
} ;

HELP: m-
{ $values { "m" sequence } }
{ $description "Subtracts the matrices element-wise." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m- ."
    "{ { 2 7 } { 11 8 } }"
  }
} ;

HELP: kronecker
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Calculates the " { $url URL" http://enwp.org/Kronecker_product" "Kronecker product" } " of two matrices." }
{ $examples
    { $example "USING: math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } { { 0 5 } { 6 7 } } kronecker ."
        "{ { 0 5 0 10 } { 6 7 12 14 } { 0 15 0 20 } { 18 21 24 28 } }" }
} ;

HELP: outer
{ $values { "u" sequence } { "v" sequence } { "m" sequence } }
{ $description "Computes the " { $url URL" http://  enwp.org/Outer_product" "outer product" } " of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples
    { $example "USING: math.matrices prettyprint ;"
        "{ 5 6 7 } { 1 2 3 } outer ."
        "{ { 5 10 15 } { 6 12 18 } { 7 14 21 } }" }
} ;
