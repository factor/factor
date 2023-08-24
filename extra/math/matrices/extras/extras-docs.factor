USING: arrays generic.single help.markup help.syntax kernel math
math.matrices math.matrices.private math.matrices.extras
math.order math.ratios math.vectors opengl.gl random sequences
urls ;
IN: math.matrices.extras

ABOUT: "math.matrices.extras"

ARTICLE: "math.matrices.extras" "Extra matrix operations"

"These constructions have special mathematical properties:"
{ $subsections
    <box-matrix>
    <hankel-matrix>
    <hilbert-matrix>
    <toeplitz-matrix>
    <vandermonde-matrix>
}

"Common transformation matrices:"
{ $subsections
    <frustum-matrix4>
    <ortho-matrix4>
    <rotation-matrix3>
    <rotation-matrix4>
    <scale-matrix3>
    <scale-matrix4>
    <skew-matrix4>
    <translation-matrix4>

    <random-integer-matrix>
    <random-unit-matrix>

}


{ $subsections
    invertible-matrix?
    linearly-independent-matrix?
}

"Common algorithms on matrices:"
{ $subsections
    gram-schmidt
    gram-schmidt-normalize
    kronecker-product
    outer-product
}

"Matrix algebra:"
{ $subsections
    rank
    nullity

} { $subsections
    determinant 1/det m*1/det
    >minors >cofactors
    multiplicative-inverse
}

"Covariance in matrices:"
{ $subsections
    covariance-matrix
    covariance-matrix-ddof
    sample-covariance-matrix
}

"Errors thrown by this vocabulary:"
{ $subsections negative-power-matrix non-square-determinant undefined-inverse } ;

HELP: invertible-matrix?
{ $values { "matrix" matrix } { "?" boolean } }
{ $description "Tests whether the input matrix has a " { $link multiplicative-inverse } ". In order for a matrix to be invertible, it must be a " { $link square-matrix } ", " { $emphasis "or" } ", if it is non-square, it must not be of " { $link +deficient-rank+ } "." }
{ $examples { $example "USING: math.matrices.extras prettyprint ;" "" } } ;

HELP: linearly-independent-matrix?
{ $values { "matrix" matrix } { "?" boolean } }
{ $description "Tests whether the input matrix is linearly independent." }
{ $examples { $example "USING: math.matrices.extras prettyprint ;" "" } } ;

! SINGLETON RANK TYPES
HELP: rank-kind
{ $class-description "The class of matrix rank quantifiers." } ;

HELP: +full-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix of full rank." } ;
HELP: +half-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix of half rank." } ;
HELP: +zero-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix of zero rank." } ;
HELP: +deficient-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix of deficient rank." } ;
HELP: +uncalculated-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix whose rank is not (yet) known." } ;

! ERRORS

HELP: negative-power-matrix
{ $values { "m" matrix } { "n" integer } }
{ $description "Throws a " { $link negative-power-matrix } " error." }
{ $error-description "Given the semantics of " { $link m^n } ", negative exponents are not within the domain of the power matrix function." } ;

HELP: non-square-determinant
{ $values { "m" integer } { "n" integer } }
{ $description "Throws a " { $link non-square-determinant } " error." }
{ $error-description { $link determinant } " was used with a non-square matrix whose dimensions are " { $snippet "m x n" } ". It is not generally possible to find the determinant of a non-square matrix." } ;

HELP: undefined-inverse
{ $values { "m" integer } { "n" integer } { "r" rank-kind } }
{ $description "Throws an " { $link undefined-inverse } " error." }
{ $error-description { $link multiplicative-inverse } " was used with a non-square matrix of rank " { $snippet "rank" } " whose dimensions are " { $snippet "m x n" } ". It is not generally possible to find the inverse of a " { $link +deficient-rank+ } " non-square " { $link matrix } "." } ;

HELP: <random-integer-matrix>
{ $values { "m" integer } { "n" integer } { "max" integer } { "matrix" matrix } }
{ $description "Creates a " { $snippet "m x n" } " " { $link matrix } " full of random, possibly signed " { $link integer } "s whose absolute values are less than or equal to " { $snippet "max" } ", as given by " { $link randoms } "." }
{ $notelist
    { "The signedness of the numbers in the resulting matrix will be randomized. Use " { $link mabs } " with this word to generate a matrix of random positive integers." }
    { $equiv-word-note "integral" <random-unit-matrix> }
}
{ $errors { $link no-method } " if " { $snippet "max" } " is not an " { $link integer } "." }
{ $examples
    { $unchecked-example
        "USING: math.matrices.extras prettyprint ;"
        "2 4 15 <random-integer-matrix> ."
        "{ { -9 -9 1 3 } { -14 -8 14 10 } }"
    }
} ;

HELP: <random-unit-matrix>
{ $values { "m" integer } { "n" integer } { "max" number } { "matrix" matrix } }
{ $description "Creates a " { $snippet "m x n" } " " { $link matrix } " full of random, possibly signed " { $link float } "s  as a fraction of " { $snippet "max" } "." }
{ $notelist
    { "The signedness of the numbers in the resulting matrix will be randomized. Use " { $link mabs } " with this word to generate a matrix of random positive numbers." }
    { $equiv-word-note "real" <random-integer-matrix> }
    { "This word is implemented by generating sub-integral floats through " { $link random-units } " and multiplying by random integers less than or equal to " { $snippet "max" } "." }
}
{ $examples
    { $unchecked-example
        "USING: math.matrices.extras prettyprint ;"
        "4 2 15 <random-unit-matrix> ."
"{
    { -3.713295909201797 3.815787135075961 }
    { -2.460506890603817 1.535222788710546 }
    { 3.692213981267878 -1.462963244399762 }
    { 13.8967592095433 -6.688509969360172 }
}"
    }
} ;



HELP: <hankel-matrix>
{ $values { "n" integer } { "matrix" matrix } }
{ $description
    "A Hankel matrix is a symmetric, " { $link square-matrix } " in which each ascending skew-diagonal from left to right is constant. See " { $url URL" https://en.wikipedia.org/wiki/Hankel_matrix" "hankel matrix" } "."
    $nl
    "The following is true of any Hankel matrix" { $snippet "A" } ": " { $snippet "A[i][j] = A[j][i] = a[i+j-2]" } "."
    $nl
    "The " { $link <toeplitz-matrix> } " is an upside-down Hankel matrix."
    $nl
    "The " { $link <hilbert-matrix> } " is a special case of the Hankel matrix."
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "4 <hankel-matrix> ."
        "{ { 1 2 3 4 } { 2 3 4 0 } { 3 4 0 0 } { 4 0 0 0 } }"
    }
} ;

HELP: <hilbert-matrix>
{ $values { "m" integer } { "n" integer } { "matrix" matrix } }
{ $description
    "A Hilbert matrix is a " { $link square-matrix } " " { $snippet "A" } " in which entries are the unit fractions "
    { $snippet "A[i][j] = 1/(i+j-1)" }
    ". See " { $url URL" https://en.wikipedia.org/wiki/Hilbert_matrix" "hilbert matrix" } "."
    $nl
    "A Hilbert matrix is a special case of the " { $link <hankel-matrix> } "."
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "1 2 <hilbert-matrix> ."
        "{ { 1 1/2 } }"
    }
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "3 6 <hilbert-matrix> ."
"{
    { 1 1/2 1/3 1/4 1/5 1/6 }
    { 1/2 1/3 1/4 1/5 1/6 1/7 }
    { 1/3 1/4 1/5 1/6 1/7 1/8 }
}"
    }
} ;

HELP: <toeplitz-matrix>
{ $values { "n" integer } { "matrix" matrix } }
{ $description "A Toeplitz matrix is an upside-down " { $link <hankel-matrix> } ". Unlike the Hankel matrix, a Toeplitz matrix can be non-square. See " { $url URL" https://en.wikipedia.org/wiki/Hankel_matrix" "hankel matrix" } "."
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "4 <toeplitz-matrix> ."
        "{ { 1 2 3 4 } { 2 1 2 3 } { 3 2 1 2 } { 4 3 2 1 } }"
    }
} ;

HELP: <box-matrix>
{ $values { "r" integer } { "matrix" matrix } }
{ $description "Create a box matrix (a " { $link square-matrix } ") with the dimensions of " { $snippet "r x r" } ", filled with ones. The number of elements in the output scales linearly (" { $snippet "(r*2)+1" } ") with " { $snippet "r" } "." }
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "2 <box-matrix> ."
"{
    { 1 1 1 1 1 }
    { 1 1 1 1 1 }
    { 1 1 1 1 1 }
    { 1 1 1 1 1 }
    { 1 1 1 1 1 }
}"
    }
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "3 <box-matrix> ."
"{
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
}"
    }

} ;

HELP: <scale-matrix3>
{ $values { "factors" sequence } { "matrix" matrix } }
{ $description "Make a " { $snippet "3 x 3" } " scaling matrix, used to scale an object in 3 dimensions. See " { $url URL" https://en.wikipedia.org/wiki/Scaling_(geometry)#Matrix_representation" "scaling matrix on Wikipedia" } "." }
{ $notelist
    { $finite-input-note "three" "factors" }
    { $equiv-word-note "3-matrix" <scale-matrix4> }
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "{ 22 33 -44 } <scale-matrix4> ."
"{
    { 22 0.0 0.0 0.0 }
    { 0.0 33 0.0 0.0 }
    { 0.0 0.0 -44 0.0 }
    { 0.0 0.0 0.0 1.0 }
}"
    }
} ;

HELP: <scale-matrix4>
{ $values { "factors" sequence } { "matrix" matrix } }
{ $description "Make a " { $snippet "4 x 4" } " scaling matrix, used to scale an object in 3 or more dimensions. See " { $url URL" https://en.wikipedia.org/wiki/Scaling_(geometry)#Matrix_representation" "scaling matrix on Wikipedia" } "." }
{ $notelist
    { $finite-input-note "three" "factors" }
    { $equiv-word-note "4-matrix" <scale-matrix3> }
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "{ 22 33 -44 } <scale-matrix4> ."
"{
    { 22 0.0 0.0 0.0 }
    { 0.0 33 0.0 0.0 }
    { 0.0 0.0 -44 0.0 }
    { 0.0 0.0 0.0 1.0 }
}"
    }
} ;

HELP: <ortho-matrix4>
{ $values { "factors" sequence } { "matrix" matrix } }
{ $description "Create a " { $link <scale-matrix4> } ", with the scale factors inverted." }
{ $notelist
    { $finite-input-note "three" "factors" }
    { $equiv-word-note "inverse" <scale-matrix4> }
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "{ -9.3 100 1/2 } <ortho-matrix4> ."
"{
    { -0.1075268817204301 0.0 0.0 0.0 }
    { 0.0 1/100 0.0 0.0 }
    { 0.0 0.0 2 0.0 }
    { 0.0 0.0 0.0 1.0 }
}"
    }
} ;

HELP: <frustum-matrix4>
{ $values { "xy-dim" pair } { "near" number } { "far" number } { "matrix" matrix } }
{ $description "Make a " { $snippet "4 x 4" } " matrix suitable for representing an occlusion frustum. A viewing or occlusion frustum is the three-dimensional region of a three-dimensional object which is visible on the screen. See " { $url URL" https://en.wikipedia.org/wiki/Frustum" "frustum on Wikipedia" } "." }
{ $notes { $finite-input-note "two" "xy-dim" } }
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "{ 5 4 } 5 6 <frustum-matrix4> ."
"{
    { 1.0 0.0 0.0 0.0 }
    { 0.0 1.25 0.0 0.0 }
    { 0.0 0.0 -11.0 -60.0 }
    { 0.0 0.0 -1.0 0.0 }
}"
    }
} ;
{ <frustum-matrix4> glFrustum } related-words

HELP: cartesian-matrix-map
{ $values { "matrix" matrix } { "quot" { $quotation ( ... pair matrix -- ... matrix' ) } } { "matrix-seq" { $sequence matrix } } }
{ $description "Calls the quotation with the matrix and the coordinate pair of the current element on the stack, with the matrix on the top of the stack." }
{ $examples
  { $example
    "USING: arrays math.matrices.extras prettyprint ;"
    "{ { 21 22 } { 23 24 } } [ 2array ] cartesian-matrix-map ."
"{
    {
        { { 0 0 } { { 21 22 } { 23 24 } } }
        { { 0 1 } { { 21 22 } { 23 24 } } }
    }
    {
        { { 1 0 } { { 21 22 } { 23 24 } } }
        { { 1 1 } { { 21 22 } { 23 24 } } }
    }
}"
  }
}
{ $notelist
  { $equiv-word-note "orthogonal" cartesian-column-map }
  { $equiv-word-note "two-dimensional" map-index }
  $2d-only-note
} ;

HELP: cartesian-column-map
{ $values { "matrix" matrix } { "quot" { $quotation ( ... pair matrix -- ... matrix' ) } } { "matrix-seq" { $sequence matrix } } }
{ $notelist
  { $equiv-word-note "orthogonal" cartesian-matrix-map }
  $2d-only-note
} ;

HELP: gram-schmidt
{ $values { "matrix" matrix } { "orthogonal" matrix } }
{ $description "Apply a Gram-Schmidt transform on the matrix." }
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "{ { 1 2 } { 3 4 } { 5 6 } } gram-schmidt ."
        "{ { 1 2 } { 4/5 -2/5 } { 0 0 } }"
    }
} ;

HELP: gram-schmidt-normalize
{ $values { "matrix" matrix } { "orthonormal" matrix } }
{ $description "Apply a Gram-Schmidt transform on the matrix, and " { $link normalize } " each row of the result, resulting in an orthogonal and normalized matrix (orthonormal)." }
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "{ { 1 2 } { 3 4 } { 5 6 } } gram-schmidt-normalize ."
"{
    { 0.4472135954999579 0.8944271909999159 }
    { 0.894427190999916 -0.447213595499958 }
    { -0/0. -0/0. }
}"
    }
} ;

HELP: m^n
{ $values { "m" matrix } { "n" object } }
{ $description "Compute the " { $snippet "nth" } " power of the input matrix. If " { $snippet "n" } " is " { $snippet "-1" } ", the inverse of the matrix is calculated (but see " { $link multiplicative-inverse } " for pitfalls)." }
{ $errors
    { $link negative-power-matrix } " if " { $snippet "n" } " is a negative number other than " { $snippet "-1" } "."
    $nl
    { $link undefined-inverse } " if " { $snippet "n" } " is " { $snippet "-1" } " and the " { $link multiplicative-inverse } " of " { $snippet "m" } " is undefined."
}
{ $notelist
    { $equiv-word-note "swapped" n^m }
    $2d-only-note
    { $matrix-scalar-note max abs / }
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "{ { 1 2 } { 3 4 } } 2 m^n ."
        "{ { 7 10 } { 15 22 } }"
    }
} ;

HELP: n^m
{ $values { "n" object } { "m" matrix } }
{ $description "Because it is nonsensical to raise a number to the power of a matrix, this word exists to save typing " { $snippet "swap m^n" } ". See " { $link m^n } " for more information." }
{ $errors
    { $link negative-power-matrix } " if " { $snippet "n" } " is a negative number other than " { $snippet "-1" } "."
    $nl
    { $link undefined-inverse } " if " { $snippet "n" } " is " { $snippet "-1" } " and the " { $link multiplicative-inverse } " of " { $snippet "m" } " is undefined."
}
{ $notelist
    { $equiv-word-note "swapped" m^n }
    $2d-only-note
    { $matrix-scalar-note max abs / }
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "2 { { 1 2 } { 3 4 } } n^m ."
        "{ { 7 10 } { 15 22 } }"
    }
} ;

HELP: kronecker-product
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Calculates the " { $url URL" http://enwp.org/Kronecker_product" "Kronecker product" } " of two matrices. This product can be described as a generalization of the vector-based " { $link outer-product } " to matrices. The Kronecker product gives the matrix of the tensor product with respect to a standard choice of basis." }
{ $notelist
    { $equiv-word-note "matrix" outer-product }
    $2d-only-note
    { $matrix-scalar-note * }
}
{ $examples
    { $unchecked-example
        "USING: math.matrices.extras prettyprint ;"
"{
    { 1 2 }
    { 3 4 }
} {
    { 0 5 }
    { 6 7 }
} kronecker-product ."
"{
    { 0 5 0 10 }
    { 6 7 12 14 }
    { 0 15 0 20 }
    { 18 21 24 28 }
}" }
} ;

HELP: outer-product
{ $values { "u" sequence } { "v" sequence } { "matrix" matrix } }
{ $description "Computes the " { $url URL" http://  enwp.org/Outer_product" "outer-product product" } " of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
        "{ 5 6 7 } { 1 2 3 } outer-product ."
        "{ { 5 10 15 } { 6 12 18 } { 7 14 21 } }" }
} ;

HELP: rank
{ $values { "matrix" matrix } { "rank" rank-kind } }
{ $contract "The " { $emphasis "rank" } " of a " { $link matrix } " is how its number of linearly independent columns compare to the maximal number of linearly independent columns for a matrix with the same dimension." }
{ $notes "See " { $url "https://en.wikipedia.org/wiki/Rank_(linear_algebra)" } " for more information." } ;

HELP: nullity
{ $values { "matrix" matrix } { "nullity" rank-kind } }
;

HELP: determinant
{ $values { "matrix" square-matrix } { "determinant" number } }
{ $contract "Compute the determinant of the input matrix. Generally, the determinant of a matrix is a scaling factor of the transformation described by the matrix." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note max - * }
}
{ $errors { $link non-square-determinant } " if the input matrix is not a " { $link square-matrix } "." }
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
"{
    {  3  0 -1 }
    { -3  1  3 }
    {  2 -5  4 }
} determinant ."
        "44"
    }
    { $example
        "USING: math.matrices.extras prettyprint ;"
"{
    { -8 -8 13 11 10 -5 -14 }
    { 3 -11 -8 3 -7 -3 4 }
    { 10 4 -5 3 0 -6 -12 }
    { -14 0 -3 -8 10 0 10 }
    { 3 -6 1 -10 -9 10 0 }
    { 5 -12 -14 6 5 -1 -7 }
    { -9 -14 -8 5 2 2 -2 }
} determinant ."
        "-103488155"
    }
} ;

HELP: 1/det
{ $values { "matrix" square-matrix } { "1/det" number } }
{ $description "Find the inverse (" { $link recip } ") of the " { $link determinant } " of the input matrix." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note determinant recip }
}
{ $errors
    { $link non-square-determinant } " if the input matrix is not a " { $link square-matrix } "."
    $nl
    { $link division-by-zero } " if the " { $link determinant } " of the input matrix is " { $snippet "0" } "."
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
"{
    { 0 10 -12 4 }
    { -9 6 -11 9 }
    { -5 -10 0 2 }
    { -7 -11 10 11 }
} 1/det ."
        "-1/9086"
    }
} ;

HELP: m*1/det
{ $values { "matrix" square-matrix } { "matrix'" square-matrix } }
{ $description "Multiply the input matrix by the inverse (" { $link recip } ") of its " { $link determinant } "." }
{ $notelist
    { "This word is used to implement " { $link recip } " for " { $link square-matrix } "." }
    $2d-only-note
    { $matrix-scalar-note determinant recip }
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
"{
    { -14 0 -13 7 }
    { -4 11 7 -12 }
    { -3 2 9 -14 }
    { 3 -5 10 -2 }
} m*1/det ."
"{
    { 7/6855 0 13/13710 -7/13710 }
    { 2/6855 -11/13710 -7/13710 2/2285 }
    { 1/4570 -1/6855 -3/4570 7/6855 }
    { -1/4570 1/2742 -1/1371 1/6855 }
}"
    }
}
;

HELP: >minors
{ $values { "matrix" square-matrix } { "matrix'" square-matrix } }
{ $description "Calculate the " { $emphasis "matrix of minors" } " of the input matrix. See " { $url URL" https://en.wikipedia.org/wiki/Minor_(linear_algebra)" "minor on Wikipedia" } "." }
{ $notelist
    $keep-shape-note
    $2d-only-note
    { $matrix-scalar-note determinant }
}
{ $errors { $link non-square-determinant } " if the input matrix is not a " { $link square-matrix } "." }
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
"{
    { -8 0 7 -11 }
    { 15 0 -3 -11 }
    { 1 -10 -4 6 }
    { 11 -15 3 -15 }
} >minors ."
"{
    { 1710 -130 2555 -1635 }
    { -690 -286 -2965 1385 }
    { 1650 -754 3795 -1215 }
    { 1100 416 2530 -810 }
}"
    }
} ;

HELP: >cofactors
{ $values { "matrix" matrix } { "matrix'" matrix } }
{ $description "Calculate the " { $emphasis "matrix of cofactors" } " of the input matrix. See " { $url URL" https://en.wikipedia.org/wiki/Minor_(linear_algebra)#Inverse_of_a_matrix" "matrix of cofactors on Wikipedia" } ". Alternating elements of the input matrix have their signs inverted." $nl "On odd rows, the even elements have their signs inverted. On even rows, odd elements have their signs inverted." }
{ $notelist
    $keep-shape-note
    $2d-only-note
    { $matrix-scalar-note neg }
}
{ $examples
    { $example
        "USING: math.matrices.extras prettyprint ;"
"{
    { 8 0 7 11 }
    { 15 0 3 11 }
    { 1 10 4 6 }
    { 11 15 3 15 }
} >cofactors ."
"{
    { 8 0 7 -11 }
    { -15 0 -3 11 }
    { 1 -10 4 -6 }
    { -11 15 -3 15 }
}"
    }
    { $example
        "USING: math.matrices.extras prettyprint ;"
"{
    { -8 0 7 -11 }
    { 15 0 -3 -11 }
    { 1 -10 -4 6 }
    { 11 -15 3 -15 }
} >cofactors ."
"{
    { -8 0 7 11 }
    { -15 0 3 -11 }
    { 1 10 -4 -6 }
    { -11 -15 -3 -15 }
}"
    }
} ;

HELP: multiplicative-inverse
{ $values { "x" matrix } { "y" matrix } }
{ $description "Calculate the multiplicative inverse of the input." $nl "If the input is a " { $link square-matrix } ", this is done by multiplying the " { $link transpose } " of the " { $link2 >cofactors "cofactors" } " of the " { $link2 >minors "minors" } " of the input matrix by the " { $link2 1/det "inverse of the determinant" } " of the input matrix."  }
{ $notelist
    $keep-shape-note
    $2d-only-note
    { $matrix-scalar-note determinant >cofactors 1/det }
}
{ $errors { $link non-square-determinant } " if the input matrix is not a " { $link square-matrix } "." } ;


HELP: covariance-matrix-ddof
{ $values { "matrix" matrix } { "ddof" object } { "cov" matrix } }
;
HELP: covariance-matrix
{ $values { "matrix" matrix } { "cov" matrix } }
;
HELP: sample-covariance-matrix
{ $values { "matrix" matrix } { "cov" matrix } }
;
HELP: population-covariance-matrix
{ $values { "matrix" matrix } { "cov" matrix } }
;
