! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, Cat Stevens.
USING: help.markup help.syntax kernel math sequences prettyprint urls ;
IN: math.matrices

ABOUT: "math.matrices"

ARTICLE: "math.matrices" "Matrix operations"
"The " { $vocab-link "math.matrices" } " vocabulary implements many ways of working with 2-dimensional sequences, known as matrices. Operations on numeric vectors are implemented in " { $vocab-link "math.vectors" } ", upon which this vocabulary relies."
$nl
"Instead of a separate matrix " { $link tuple } " to be instantiated, words in this vocabulary operate on 2-dimensional sequences. In this vocabulary's stack effects, " { $snippet "m" } " and " { $snippet "matrix" } " are the conventional names used for a given matrix object."
$nl
"Making simple matrices:"
{ $subsections
    <matrix>
    <matrix-by>
    <matrix-by-indices>
    <zero-matrix>
    <zero-square-matrix>
    <diagonal-matrix>
    <identity-matrix>
    <simple-eye>
    <eye>
    <square-rows>
    <square-cols>
    <upper-matrix>
    <lower-matrix>
    <cartesian-square-indices>
}

"Making special kinds of matrices:"
{ $subsections
    <box-matrix>
    <hankel-matrix>
    <hilbert-matrix>
    <toeplitz-matrix>
    <vandermonde-matrix>
}

"Making domain-specific transformation matrices:"
{ $subsections
    <frustum-matrix4>
    <ortho-matrix4>
    <rotation-matrix3>
    <rotation-matrix4>
    <scale-matrix3>
    <scale-matrix4>
    <skew-matrix4>
    <translation-matrix4>
}

"By-element mathematical operations of a matrix and a scalar:"
{ $subsections mneg n+m m+n n-m m-n n*m m*n n/m m/n m^n }

"By-element mathematical operations of two matricess:"
{ $subsections m+ m- m* m/ m~ }

"Dot product (multiplication) of vectors and matrices:"
{ $subsections v.m m.v m. }

"Transformations on matrices:"
{ $subsections
    matrix-map
    cartesian-matrix-map
    cartesian-matrix-column-map
    column-map
    gram-schmidt
    gram-schmidt-normalize
    stitch
    kronecker
    outer
    upper-matrix-indices
    lower-matrix-indices
}

"Covariance in matrices:"
{ $subsections
    covariance-matrix
    covariance-matrix-ddof
    sample-covariance-matrix
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
  matrix-set-nth
  matrix-set-nths
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

! creators

HELP: <matrix>
{ $values { "m" integer } { "n" integer } { "element" object } { "matrix" sequence } }
{ $description "Creates a matrix of size " { $snippet "m x n" } ", filled with " { $snippet "element" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "3 2 10 <matrix> ."
        "{ { 10 10 } { 10 10 } { 10 10 } }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "4 1 \"¢\" <matrix> ."
        "{ { \"¢\" } { \"¢\" } { \"¢\" } { \"¢\" } }"
    }
} ;

HELP: <matrix-by>
{ $values { "m" integer } { "n" integer } { "quot" { $quotation ( ... -- elt ) } } }
{ $description "Creates a matrix of size " { $snippet "m x n" } " using elements given by " { $snippet "quot" } "."  }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 5 [ 5 ] <matrix-by> ."
        "{ { 5 5 5 5 5 } { 5 5 5 5 5 } { 5 5 5 5 5 } { 5 5 5 5 5 } }"
    }
} ;

{ <matrix> <matrix-by> <matrix-by-indices> } related-words

HELP: <zero-matrix>
{ $values { "m" integer } { "n" integer } { "matrix" sequence } }
{ $description "Creates a matrix of size " { $snippet "m x n" } ", filled with zeroes." } ;

HELP: <zero-square-matrix>
{ $values { "m" integer } { "matrix" sequence } }
{ $description "Creates a matrix of size " { $snippet "n x n" } ", filled with zeroes. Shorthand for " { $code "n n <zero-matrix>" } "." } ;

HELP: <diagonal-matrix>
{ $values { "diagonal-seq" sequence } { "matrix" sequence } }
{ $description "Creates a matrix with the specified diagonal values." }
{ $examples
  { $example
      "USING: math.matrices prettyprint ;"
      "{ 1 2 3 } <diagonal-matrix> ."
      "{ { 1 0 0 } { 0 2 0 } { 0 0 3 } }"
  }
} ;

HELP: <identity-matrix>
{ $values { "n" integer } { "matrix" sequence } }
{ $description "Creates an " { $url URL" http://enwp.org/Identity_matrix" "identity matrix" } " of size " { $snippet "n x n" } ", where the diagonal values are all ones." } ;

HELP: <eye>
{ $values { "m" integer } { "n" integer } { "k" integer } { "z" object } { "matrix" sequence } }
{ $description "Creates an " { $snippet "m x n" } " matrix with a diagonal of " { $snippet "z" } " offset by " { $snippet "k" } " from the main diagonal. A positive value of " { $snippet "k" } " gives a diagonal above the main diagonal, whereas a negative value of " { $snippet "k" } " gives a diagonal below the main diagonal." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "5 6 0 4 <eye> ."
        "{
    { 4 0 0 0 0 0 }
    { 0 4 0 0 0 0 }
    { 0 0 4 0 0 0 }
    { 0 0 0 4 0 0 }
    { 0 0 0 0 4 0 }
}"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "5 5 2 2 <eye> ."
        "{
    { 0 0 2 0 0 }
    { 0 0 0 2 0 }
    { 0 0 0 0 2 }
    { 0 0 0 0 0 }
    { 0 0 0 0 0 }
}"
    }
} ;

HELP: <simple-eye>
{ $values { "m" integer } { "n" integer } { "k" integer } { "matrix" sequence } }
{ $description "Creates an " { $snippet "m x n" } " matrix with a diagonal of ones offset by " { $snippet "k" } " from the main diagonal. The following are equivalent for any " { $snippet "m n k" } ":" { $code "m n k 1 <eye>" } { $code "m n k <simple-eye>" } $nl "Specify a different diagonal value with " { $link <eye> } "." } ;

{ <zero-matrix> <diagonal-matrix> <identity-matrix> <eye> <simple-eye> } related-words

{ <square-rows> <square-cols> } related-words

HELP: n+m
{ $values { "n" object } { "m" sequence }  }
{ $description { $snippet "n" } " is treated as a scalar and added to each element of the matrix " { $snippet "m" } ". " }
{ $examples
  { $example
    "USING: kernel math.matrices prettyprint ;"
    "3 <identity-matrix> 1 swap n+m ."
    "{ { 2 1 1 } { 1 2 1 } { 1 1 2 } }"
  }
} ;

{ n+m m+n n-m m-n n*m m*n n/m m/n } related-words

HELP: m+
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Adds two matrices element-wise." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 1 2 3 } { 3 2 1 } } { { 4 5 6 } { 6 5 4 } } m+ ."
    "{ { 5 7 9 } { 9 7 5 } }"
  }
} ;

HELP: m-
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Subtracts two matrices element-wise." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 4 5 6 } { 6 5 4 } } { { 1 2 3 } { 3 2 1 } } m- ."
    "{ { 3 3 3 } { 3 3 3 } }"
  }
} ;

HELP: m*
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Multiplies two matrices element-wise." }
{ $examples
  { $example
      "USING: math.matrices prettyprint ;"
      "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m* ."
      "{ { 15 18 } { 60 153 } }"
  }
} ;

HELP: m/
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Divides two matrices element-wise." }
{ $examples
  { $example
      "USING: math.matrices prettyprint ;"
      "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m/ ."
      "{ { 1+2/3 4+1/2 } { 3+3/4 1+8/9 } }"
  }
} ;

HELP: m~
{ $values { "m1" sequence } { "m2" sequence } { "epsilon" number } { "?" boolean } }
{ $description "Compares the matrices using the " { $snippet "epsilon" } "." }
{ $examples
  { $example
      "USING: kernel math math.matrices prettyprint ;"
      "{ { 5 9 } { 15 17 } } dup [ .01 + ] matrix-map .1 m~ ."
      "t"
  }
} ;

{ m+ m- m* m/ m~ } related-words

HELP: mneg
{ $values { "m" sequence } { "m" object } }
{ $description "Negate (invert the sign) of all elements in the matrix." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 5 9 } { 15 17 } } mneg ."
    "{ { -5 -9 } { -15 -17 } }"
  }
} ;

HELP: mmin
{ $values { "m" sequence } { "n" object } }
{ $description "Calculate the minimum value of all elements in the matrix." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 5 9 } { 15 17 } } mmin ."
    "5"
  }
} ;

HELP: mmax
{ $values { "m" sequence } { "n" object } }
{ $description "Calculate the maximum value of all elements in the matrix." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 5 9 } { 15 17 } } mmin ."
    "17"
  }
} ;

HELP: mnorm
{ $values { "m" sequence } { "m'" object } }
{ $description "Calculate the normal value of each element in the matrix. This makes the maximum value in the sequence " { $snippet "1/1" } ", and computes other elements as fractions of this maximum. The output is a matrix, containing each original element as a fraction of the maximum." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 5 9 } { 15 17 } } mnorm ."
    "{ { 5/17 9/17 } { 15/17 1 } }"
  }
} ;

{ mmin mmax mnorm mneg } related-words

HELP: m.v
{ $values { "m" sequence } { "v" sequence } { "p" sequence } }
{ $description "Computes the dot product between a matrix and a vector." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ { 1 -1 2 } { 0 -3 1 } } { 2 1 0 } m.v ."
    "{ 1 -3 }"
  }
} ;

HELP: v.m
{ $values { "m" sequence } { "v" sequence } { "p" sequence } }
{ $description "Computes the dot product between a vector and a matrix." }
{ $examples
  { $example
    "USING: math.matrices prettyprint ;"
    "{ 2 1 0 } { { 1 -1 2 } { 0 -3 1 } } v.m ."
    "{ 2 -5 5 }"
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

{ m. v.m m.v } related-words

HELP: stitch
{ $values { "m" sequence } { "m'" sequence } }
{ $description
  "Folds an " { $snippet "n>2" } "-dimensional matrix onto itself."
}
{ $examples
  { $unchecked-example
    "USING: math.matrices prettyprint ;"
    "{
  { { 0 5 } { 6 7 } { 0 15 } { 18 21 } }
  { { 0 10 } { 12 14 } { 0 20 } { 24 28 } }
} stitch ."
    "{
  { 0 5 0 10 }
  { 6 7 12 14 }
  { 0 15 0 20 }
  { 18 21 24 28 }
}"
  }
} ;

HELP: kronecker
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Calculates the " { $url URL" http://enwp.org/Kronecker_product" "Kronecker product" } " of two matrices." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } { { 0 5 } { 6 7 } } kronecker ."
        "{ { 0 5 0 10 } { 6 7 12 14 } { 0 15 0 20 } { 18 21 24 28 } }" }
} ;

HELP: outer
{ $values { "u" sequence } { "v" sequence } { "m" sequence } }
{ $description "Computes the " { $url URL" http://  enwp.org/Outer_product" "outer product" } " of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 5 6 7 } { 1 2 3 } outer ."
        "{ { 5 10 15 } { 6 12 18 } { 7 14 21 } }" }
} ;
