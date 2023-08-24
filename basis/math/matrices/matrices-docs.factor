! Copyright (C) 2005, 2010, 2018, 2020 Slava Pestov, Joe Groff, and Cat Stevens.
USING: arrays assocs help.markup help.markup.private help.syntax
kernel math math.functions math.order math.vectors sequences
sequences.generalizations urls ;
IN: math.matrices

<PRIVATE
! like $subsections but skip the extra blank line
: $subs-nobl ( children -- )
    [ $subsection* ] each ;

! swapped and n-matrix variants
: $equiv-word-note ( children -- )
    [ "This word is the " ] dip
    first2
    " variant of " swap
    [ { $link } ] dip suffix
    "."
    5 narray print-element ;

! words like <scale-matrix3> which have an array of inputs
: $finite-input-note ( children -- )
    [ "Only the first " ] dip
    first2
    " values in " swap
    [ { $snippet } ] dip suffix
    " are used."
    5 narray print-element ;

! a note for when a word assumes a 2d matrix
: $2d-only-note ( children -- )
    drop { "This word is intended for use with \"flat\" (2-dimensional) matrices. "
      ! "Using it with matrices of 3 or more dimensions may lead to unexpected results."
    }
    print-element ;

! a note for numeric-specific operations
: $matrix-scalar-note ( children -- )
    \ $subs-nobl prefix
    "This word assumes that elements of the input matrix are compatible with the following words:"
    swap 2array
    print-element ;

: $keep-shape-note ( children -- )
    drop { "The shape of the input matrix is preserved in the output." } print-element ;

: $link2 ( children -- )
    first2 swap [ write-link ] topic-span ;

! so that we don't end up with multiple $notes calls leading to multiple Notes sections
: $notelist ( children -- )
    \ $list prefix $notes ;
PRIVATE>

ABOUT: "math.matrices"

ARTICLE: "math.matrices" "Matrix operations"

"The " { $vocab-link "math.matrices" } " vocabulary implements many ways of working with " { $emphasis "matrices" } " — sequences which have a minimum of 2 dimensions. Operations on 1-dimensional numeric vectors are implemented in " { $vocab-link "math.vectors" } ", upon which this vocabulary relies."
$nl
"In this vocabulary's documentation, " { $snippet "m" } " and " { $snippet "matrix" } " are the conventional names used for a given matrix object. " { $snippet "m" } " may also refer to a number."
$nl
"The " { $vocab-link "math.matrices.extras" } " vocabulary implements extensions to this one."
$nl
"Matrices are classified their mathematical properties, and by predicate words:"
$nl
! split up intentionally
{ $subsections
    matrix
    irregular-matrix
    square-matrix
    zero-matrix
    zero-square-matrix
    null-matrix

} { $subsections
    matrix?
    irregular-matrix?
    square-matrix?
    zero-matrix?
    zero-square-matrix?
    null-matrix?
}

"There are many ways to create 2-dimensional matrices:"
{ $subsections
    <matrix>
    <matrix-by>
    <matrix-by-indices>

} { $subsections
    <zero-matrix>
    <zero-square-matrix>
    <diagonal-matrix>
    <anti-diagonal-matrix>
    <identity-matrix>
    <simple-eye>
    <eye>

} { $subsections
    <coordinate-matrix>
    <square-rows>
    <square-cols>
    <upper-matrix>
    <lower-matrix>
    <cartesian-square-indices>
}

"By-element mathematical operations on a matrix:"
{ $subsections matrix-normalize mneg m+n m-n m*n m/n n+m n-m n*m n/m }

"By-element mathematical operations of two matrices:"
{ $subsections m+ m- m* m/ m~ }

"Dot product (multiplication) of vectors and matrices:"
{ $subsections vdotm mdotv mdot }

"Transformations and elements of matrices:"
{ $subsections
    dimension
    transpose anti-transpose
    matrix-nth matrix-nths
    matrix-set-nth matrix-set-nths

} { $subsections
    row rows rows-except
    col cols cols-except

} { $subsections
    matrix-except matrix-except-all

} { $subsections
    matrix-map column-map stitch

} { $subsections
    main-diagonal
    anti-diagonal
}

"The following matrix norms are provided in the 𝑙ₚ and " { $snippet "L^p,q" } " vector spaces; these words are equivalent to ∥･∥ₚ and ∥･∥^p,q for " { $snippet "p = 1, 2, ∞, ℝ" } ", and " { $snippet "p, q ∈ ℝ" } ", respectively:"
{ $subsections
    matrix-l1-norm
    matrix-l2-norm
    matrix-l-infinity-norm
    matrix-p-norm
    matrix-p-q-norm
}
"For readability, user code should prefer the available generic versions of the above, from " { $vocab-link "math.vectors" } ", which are optimized the same:"
{ $subsections
  l1-norm l2-norm l-infinity-norm p-norm
} ;

! PREDICATE CLASSES

HELP: matrix
{ $class-description "The class of regular, rectangular matrices. In mathematics and linear algebra, a matrix is a rectangular collection of scalar elements for the purpose of the uniform application of algorithms." }
{ $notes "In Factor, any sequence with two or more dimensions (one or more layers of subsequences) can be a " { $link matrix } ", and the elements may be any " { $link object } "."
$nl "A regular matrix is a sequence with two or more dimensions, whose subsequences are all of equal length. See " { $link regular-matrix? } "." }
$nl "Irregular matrices are classified by " { $link irregular-matrix } "." ;

HELP: irregular-matrix
{ $class-description "The most common matrix, and most easily manipulated by this vocabulary, is rectangular. This predicate classifies irregular (non-rectangular) matrices." } ;

HELP: square-matrix
{ $class-description "The class of square matrices. A square matrix is a " { $link matrix } " which has the same number of rows and columns. In other words, its outermost two dimensions are of equal size." } ;

HELP: zero-matrix
{ $class-description "The class of zero matrices. A zero matrix is a matrix whose only elements are the scalar " { $snippet "0" } "." }
{ $notes "In mathematics, a zero-filled matrix is called a null matrix. In Factor, a " { $link null-matrix } " is an empty matrix." } ;

HELP: zero-square-matrix
{ $class-description "The class of square zero matrices. This predicate is a composition of " { $link zero-matrix } " and " { $link square-matrix } "." } ;

HELP: null-matrix
{ $class-description "The class of null matrices. A null matrix is an empty sequence, or a sequence which consists only of empty sequences." }
{ $notes "In mathematics, a null matrix is a matrix full of zeroes. In Factor, such a matrix is called a " { $link zero-matrix } "." } ;

{ matrix irregular-matrix square-matrix zero-matrix null-matrix zero-square-matrix null-matrix } related-words

! NON-PREDICATE TESTS

HELP: regular-matrix?
{ $values { "object" object } { "?" boolean } }
{ $description "Tests if the object is a regular (well-formed, rectangular, etc) " { $link matrix } ". A regular matrix is a sequence with an equal number of elements in every row, and an equal number of elements in every column, such that there are no empty slots." }
{ $notes "The " { $link null-matrix } " is considered regular, because of semantic requirements of the matrix implementation." }
{ $examples
    "The example is an irregular matrix, because the rows have an unequal number of elements."
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 } { } } regular-matrix? ."
        "f"
    }
    "The example is a regular matrix, because the rows have an equal number of elements."
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 } { 2 } } regular-matrix? ."
        "t"
    }
} ;

! BUILDERS
HELP: <matrix>
{ $values { "m" integer } { "n" integer } { "element" object } { "matrix" matrix } }
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
{ $values { "m" integer } { "n" integer } { "quot" { $quotation ( ... -- elt ) } } { "matrix" matrix } }
{ $description "Creates a matrix of size " { $snippet "m x n" } " using elements given by " { $snippet "quot" } ", a quotation called to create each element."  }
{ $notes "The following are equivalent:"
  { $code "m n [ 2drop foo ] <matrix-by-indices>" }
  { $code "m n [ foo ] <matrix-by>" }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 5 [ 5 ] <matrix-by> ."
        "{ { 5 5 5 5 5 } { 5 5 5 5 5 } { 5 5 5 5 5 } { 5 5 5 5 5 } }"
    }
} ;

HELP: <matrix-by-indices>
{ $values { "m" integer } { "n" integer } { "quot" { $quotation ( ... m' n' -- ... elt ) } } { "matrix" matrix } }
{ $description "Creates an " { $snippet "m x n" } " " { $link matrix } " using elements given by " { $snippet "quot" } " . This word differs from " { $link <matrix-by> } " in that the indices are placed on the stack (in the same order) before " { $snippet "quot" } " runs. The output of the quotation will be the element at the given position in the matrix." }
{ $notes "The following are equivalent:"
  { $code "m n [ 2drop foo ] <matrix-by-indices>" }
  { $code "m n [ foo ] <matrix-by>" }
}
{ $examples
    { $example
        "USING: math math.matrices prettyprint ;"
        "3 4 [ * ] <matrix-by-indices> ."
        "{ { 0 0 0 0 } { 0 1 2 3 } { 0 2 4 6 } }"
    }
} ;

HELP: <zero-matrix>
{ $values { "m" integer } { "n" integer } { "matrix" matrix } }
{ $description "Creates a matrix of size " { $snippet "m x n" } ", filled with zeroes." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "2 3 <zero-matrix> ."
        "{ { 0 0 0 } { 0 0 0 } }"
    }
} ;

HELP: <zero-square-matrix>
{ $values { "n" integer } { "matrix" matrix } }
{ $description "Creates a matrix of size " { $snippet "n x n" } ", filled with zeroes. Shorthand for " { $code "n n <zero-matrix>" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "2 <zero-square-matrix> ."
        "{ { 0 0 } { 0 0 } }"
    }
} ;

HELP: <diagonal-matrix>
{ $values { "diagonal-seq" sequence } { "matrix" matrix } }
{ $description "Creates a matrix with the specified main diagonal. This word has the opposite effect of " { $link main-diagonal } "." }
{ $notes "To use a diagonal starting in the lower right, reverse the input sequence before calling this word." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 1 2 3 } <diagonal-matrix> ."
        "{ { 1 0 0 } { 0 2 0 } { 0 0 3 } }"
    }
} ;

HELP: <anti-diagonal-matrix>
{ $values { "diagonal-seq" sequence } { "matrix" matrix } }
{ $description "Creates a matrix with the specified anti-diagonal. This word has the opposite effect of " { $link anti-diagonal } "." }
{ $notes "To use a diagonal starting in the lower left, reverse the input sequence before calling this word." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 1 2 3 } <anti-diagonal-matrix> ."
        "{ { 0 0 1 } { 0 2 0 } { 3 0 0 } }"
    }
} ;

HELP: <identity-matrix>
{ $values { "n" integer } { "matrix" matrix } }
{ $description "Creates an " { $url URL" http://enwp.org/Identity_matrix" "identity matrix" } " of size " { $snippet "n x n" } ", where the diagonal values are all ones." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 <identity-matrix> ."
        "{ { 1 0 0 0 } { 0 1 0 0 } { 0 0 1 0 } { 0 0 0 1 } }"
    }
} ;

HELP: <eye>
{ $values { "m" integer } { "n" integer } { "k" integer } { "z" object } { "matrix" matrix } }
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
{ $values { "m" integer } { "n" integer } { "k" integer } { "matrix" matrix } }
{ $description
    "Creates an " { $snippet "m x n" } " matrix with a diagonal of ones offset by " { $snippet "k" } " from the main diagonal."
    "The following are equivalent for any " { $snippet "m n k" } ":" { $code "m n k 1 <eye>" } { $code "m n k <simple-eye>" }
    $nl
    "Specify a different diagonal value with " { $link <eye> } "."
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 5 2 <simple-eye> ."
        "{ { 0 0 1 0 0 } { 0 0 0 1 0 } { 0 0 0 0 1 } { 0 0 0 0 0 } }"
    }
} ;

HELP: <coordinate-matrix>
{ $values { "dim" pair } { "coordinates" matrix } }
{ $description "Create a matrix in which each element is its own coordinate pair, also called a " { $link cartesian-product } "." }
{ $notelist
    { $equiv-word-note "non-square" <cartesian-square-indices> }
    { $finite-input-note "two" "dim" }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 4 } <coordinate-matrix> ."
"{
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
}"
    }
} ;

HELP: <cartesian-indices>
{ $values { "dim" pair } { "coordinates" matrix } }
{ $description "An alias for " { $link <coordinate-matrix> } " which serves as the logical non-square companion to " { $link <cartesian-square-indices> } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 4 } <cartesian-indices> ."
"{
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
}"
    }
} ;

HELP: <cartesian-square-indices>
{ $values { "n" integer } { "matrix" square-matrix } }
{ $description "Create a " { $link square-matrix } " full of " { $link cartesian-product } "s. See " { $url URL" https://en.wikipedia.org/wiki/Cartesian_product" "cartesian product" } "." }
{ $notes
    { $equiv-word-note "square" <cartesian-indices> }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "1 <cartesian-square-indices> ."
        "{ { { 0 0 } } }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "3 <cartesian-square-indices> ."
"{
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
}"
    }
} ;

HELP: <square-rows>
{ $values { "desc" { $or sequence integer matrix } } { "matrix" matrix } }
{ $contract "Generate a " { $link square-matrix } " from a descriptor." }
{ $description "If the descriptor is an " { $link integer } ", it is used to generate square rows within that range." $nl "If it is a 1-dimensional sequence, it is " { $link replicate } "d to create each row." $nl "If it is a " { $link matrix } ", it is cropped into a " { $link square-matrix } "." $nl "If it is a " { $link square-matrix } ", it is returned unchanged." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "3 <square-rows> ."
        "{ { 0 1 2 } { 0 1 2 } { 0 1 2 } }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 3 5 } <square-rows> ."
        "{ { 2 3 5 } { 2 3 5 } { 2 3 5 } }"
    }
} ;

HELP: <square-cols>
{ $values { "desc" { $or sequence integer matrix } } { "matrix" matrix } }
{ $contract "Generate a " { $link square-matrix } " from a descriptor." }
{ $description "If the descriptor is an " { $link integer } ", it is used to generate square columns within that range." $nl "If it is a 1-dimensional sequence, it is " { $link replicate } "d to create each column." $nl "If it is a " { $link matrix } ", it is cropped into a " { $link square-matrix } "." $nl "If it is a " { $link square-matrix } ", it is returned unchanged." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "3 <square-cols> ."
        "{ { 0 0 0 } { 1 1 1 } { 2 2 2 } }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 3 5 } <square-cols> ."
        "{ { 2 2 2 } { 3 3 3 } { 5 5 5 } }"
    }
} ;

HELP: <lower-matrix>
{ $values { "object" object } { "m" integer } { "n" integer } { "matrix" matrix } }
{ $description "Make a lower triangular matrix, where all the values above the main diagonal are " { $snippet "0" } ". " { $snippet "object" } " will be used as the value for the nonzero part of the matrix, while " { $snippet "m" } " and " { $snippet "n" } " are used as the dimensions. The inverse of this word is " { $link <upper-matrix> } ". See " { $url URL" https://en.wikipedia.org/wiki/Triangular_matrix" "triangular matrix" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "1 5 5 <lower-matrix> ."
"{
    { 1 0 0 0 0 }
    { 1 1 0 0 0 }
    { 1 1 1 0 0 }
    { 1 1 1 1 0 }
    { 1 1 1 1 1 }
}"
    }
} ;

HELP: <upper-matrix>
{ $values { "object" object } { "m" integer } { "n" integer } { "matrix" matrix } }
{ $description "Make an upper triangular matrix, where all the values below the main diagonal are " { $snippet "0" } ". " { $snippet "object" } " will be used as the value for the nonzero part of the matrix, while " { $snippet "m" } " and " { $snippet "n" } " are used as the dimensions. The inverse of this word is " { $link <lower-matrix> } ". See " { $url URL" https://en.wikipedia.org/wiki/Triangular_matrix" "triangular matrix" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "1 5 5 <upper-matrix> ."
"{
    { 1 1 1 1 1 }
    { 0 1 1 1 1 }
    { 0 0 1 1 1 }
    { 0 0 0 1 1 }
    { 0 0 0 0 1 }
}"
    }
} ;

HELP: stitch
{ $values { "m" matrix } { "m'" matrix } }
{ $description "Folds an " { $snippet "n>2" } "-dimensional matrix onto itself." }
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

HELP: row
{ $values { "n" integer } { "matrix" matrix } { "row" sequence } }
{ $description "Get the nth row of the matrix." }
{ $notes "Like most Factor sequences, indexing is 0-based. The first row is given by " { $snippet "m 0 row" } "." }
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } 1 swap row ."
        "{ 3 4 }"
    }
} ;

HELP: rows
{ $values { "seq" sequence } { "matrix" matrix } { "rows" sequence } }
{ $description "Get the rows from " { $snippet "matrix" } " listed by " { $snippet "seq" } "." }
{ $notelist { $equiv-word-note "multiplexing" row } }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 0 1 } { { 1 2 } { 3 4 } } rows ."
        "{ { 1 2 } { 3 4 } }"
    }
} ;

HELP: col
{ $values { "n" integer } { "matrix" matrix } { "col" sequence } }
{ $description "Get the " { $snippet "n" } "th column of the matrix." }
{ $notes "Like most Factor sequences, indexing is 0-based. The first column is given by " { $snippet "m 0 col" } "." }
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } 1 swap col ."
        "{ 2 4 }"
    }
} ;

HELP: cols
{ $values { "seq" sequence } { "matrix" matrix } { "cols" sequence } }
{ $description "Get the columns from " { $snippet "matrix" } " listed by " { $snippet "seq" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 0 1 } { { 1 2 } { 3 4 } } cols ."
        "{ { 1 3 } { 2 4 } }"
    }
} ;

HELP: >square-matrix
{ $values { "m" matrix } { "subset" square-matrix } }
{ $description "Find only the " { $link2 square-matrix "square" } " subset of the input matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 0 2 4 6 } { 1 3 5 7 } } >square-matrix ."
        "{ { 0 2 } { 1 3 } }"
    }
} ;

HELP: matrix-map
{ $values { "matrix" matrix } { "quot" { $quotation ( ... elt -- ... elt' ) } } { "matrix'" matrix } }
{ $description "Apply the quotation to every element of the matrix." }
{ $notelist $2d-only-note }
{ $examples
    { $example
        "USING: math.matrices kernel math prettyprint ;"
        "3 <identity-matrix> [ zero? 15 -8 ? ] matrix-map ."
        "{ { -8 15 15 } { 15 -8 15 } { 15 15 -8 } }"
    }
} ;

HELP: column-map
{ $values { "matrix" matrix } { "quot" { $quotation ( ... col -- ... col' ) } } { "matrix'" { $maybe sequence matrix } } }
{ $description "Apply the quotation to every column of the matrix. The output of the quotation must be a sequence." }
{ $notelist $2d-only-note { $equiv-word-note "transpose" map } }
{ $examples
    { $example
        "USING: sequences math.matrices prettyprint ;"
        "3 <identity-matrix> [ reverse ] column-map ."
        "{ { 0 0 1 } { 0 1 0 } { 1 0 0 } }"
    }
} ;

HELP: matrix-nth
{ $values { "pair" pair } { "matrix" matrix } { "elt" object } }
{ $description "Retrieve the element in the matrix at the zero-indexed " { $snippet "row, column" } " pair." }
{ $notelist { $equiv-word-note "two-dimensional" nth } $2d-only-note }
{ $errors { $list
    { { $link bounds-error } " if the first element in " { $snippet "pair" } " is greater than the maximum row index in " { $snippet "matrix" } }
    { { $link bounds-error } " if the second element in " { $snippet "pair" } " is greater than the maximum column index in " { $snippet "matrix" } }
} }
{ $examples
    "Get the entry at row 1, column 0."
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 1 0 } { { 0 1 } { 2 3 } } matrix-nth ."
        "2"
    }
} ;

HELP: matrix-nths
{ $values { "pairs" assoc } { "matrix" matrix } { "elts" sequence } }
{ $description "Retrieve all the elements in the matrix at each of the zero-indexed " { $snippet "row, column" } " pairs in " { $snippet "pairs" } "." }
{ $notelist { $equiv-word-note "two-dimensional" nths } $2d-only-note }
{ $errors { $list
    { { $link bounds-error } " if the first element of a pair in " { $snippet "pairs" } " is greater than the maximum row index in " { $snippet "matrix" } }
    { { $link bounds-error } " if the second element of a pair in " { $snippet "pairs" } " is greater than the maximum column index in " { $snippet "matrix" } }
} }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 0 } { 1 1 } } { { 0 1 } { 2 3 } } matrix-nths ."
        "{ 2 3 }"
    }
} ;

HELP: matrix-set-nth
{ $values { "obj" object } { "pair" pair } { "matrix" matrix } }
{ $description "Set the element in the matrix at the 2D index given by " { $snippet "pair" } " to " { $snippet "obj" } ". This operation is destructive." }
{ $side-effects "matrix" }
{ $notelist { $equiv-word-note "two-dimensional" set-nth } $2d-only-note  }
{ $errors { $list
    { { $link bounds-error } " if the first element of a pair in " { $snippet "pairs" } " is greater than the maximum row index in " { $snippet "matrix" } }
    { { $link bounds-error } " if the second element of a pair in " { $snippet "pairs" } " is greater than the maximum column index in " { $snippet "matrix" } }
    "Throws an error if the sequence cannot hold elements of the given type."
} }
{ $examples
    "Change the entry at row 1, column 0."
    { $example
        "USING: math.matrices kernel prettyprint ;"
        "{ { 0 1 } { 2 3 } } \"a\" { 1 0 } pick matrix-set-nth ."
        "{ { 0 1 } { \"a\" 3 } }"
    }
} ;

HELP: matrix-set-nths
{ $values { "obj" object } { "pairs" assoc } { "matrix" matrix } }
{ $description "Applies " { $link matrix-set-nth } " to " { $snippet "matrix" } " for each " { $snippet "row, column" } " pair in " { $snippet "pairs" } ", setting the elements to " { $snippet "obj" } "." }
{ $side-effects "matrix" }
{ $notelist { $equiv-word-note "multiplexing" matrix-set-nth } $2d-only-note }
{ $errors { $list
    { { $link bounds-error } " if the first element of a pair in " { $snippet "pairs" } " is greater than the maximum row index in " { $snippet "matrix" } }
    { { $link bounds-error } " if the second element of a pair in " { $snippet "pairs" } " is greater than the maximum column index in " { $snippet "matrix" } }
    "Throws an error if the sequence cannot hold elements of the given type."
} }
{ $examples
    "Change both entries on row 1."
    { $example
        "USING: math.matrices kernel prettyprint ;"
        "{ { 0 1 } { 2 3 } } \"a\" { { 1 0 } { 1 1 } } pick matrix-set-nths ."
        "{ { 0 1 } { \"a\" \"a\" } }"
    }
} ;


HELP: mneg
{ $values { "m" matrix } { "m'" matrix } }
{ $description "Negate (invert the sign) of every element in the matrix. The resulting matrix is called the " { $emphasis "additive inverse" } " of the input matrix." }
{ $notelist
    { $equiv-word-note "companion" mabs }
    $2d-only-note
    { $matrix-scalar-note neg }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 -17 } } mneg ."
        "{ { -5 -9 } { -15 17 } }"
    }
} ;

HELP: mabs
{ $values { "m" matrix } { "m'" matrix } }
{ $description "Compute the absolute value (" { $link abs } ") of each element in the matrix." }
{ $notelist
    { $equiv-word-note "companion" mneg }
    $2d-only-note
    { $matrix-scalar-note abs }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { -5 -9 } { -15 17 } } mabs ."
        "{ { 5 9 } { 15 17 } }"
    }
} ;

HELP: n+m
{ $values { "n" object } { "m" matrix }  }
{ $description { $snippet "n" } " is treated as a scalar and added to each element of the matrix " { $snippet "m" } "." }
{ $notelist
    { $equiv-word-note "swapped" m+n }
    $2d-only-note
    { $matrix-scalar-note + }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "1 3 <identity-matrix> n+m ."
        "{ { 2 1 1 } { 1 2 1 } { 1 1 2 } }"
    }
} ;

HELP: m+n
{ $values { "m" matrix } { "n" object } }
{ $description { $snippet "n" } " is treated as a scalar and added to each element of the matrix " { $snippet "m" } "." }
{ $notelist
    { $equiv-word-note "swapped" n+m }
    $2d-only-note
    { $matrix-scalar-note + }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 <identity-matrix> 1 m+n ."
        "{ { 2 1 1 } { 1 2 1 } { 1 1 2 } }"
    }
} ;

HELP: n-m
{ $values { "n" object } { "m" matrix }  }
{ $description { $snippet "n" } " is treated as a scalar and subtracted from each element of the matrix " { $snippet "m" } "." }
{ $notelist
    { $equiv-word-note "swapped" m-n }
    $2d-only-note
    { $matrix-scalar-note - }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "1 3 <identity-matrix> n-m ."
        "{ { 0 1 1 } { 1 0 1 } { 1 1 0 } }"
    }
} ;

HELP: m-n
{ $values { "m" matrix } { "n" object } }
{ $description { $snippet "n" } " is treated as a scalar and subtracted from each element of the matrix " { $snippet "m" } "." }
{ $notelist
    { $equiv-word-note "swapped" n-m }
    $2d-only-note
    { $matrix-scalar-note - }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 <identity-matrix> 1 m-n ."
        "{ { 0 -1 -1 } { -1 0 -1 } { -1 -1 0 } }"
    }
} ;

HELP: n*m
{ $values { "n" object } { "m" matrix }  }
{ $description "Every element in the input matrix " { $snippet "m" } " is multiplied by the scalar " { $snippet "n" } "." }
{ $notelist
    $keep-shape-note
    { $equiv-word-note "swapped" m*n }
    $2d-only-note
    { $matrix-scalar-note * }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 3 <identity-matrix> n*m ."
        "{ { 3 0 0 } { 0 3 0 } { 0 0 3 } }"
    }
} ;

HELP: m*n
{ $values { "m" matrix } { "n" object } }
{ $description "Every element in the input matrix " { $snippet "m" } " is multiplied by the scalar " { $snippet "n" } "." }
{ $notelist
    $keep-shape-note
    { $equiv-word-note "swapped" n*m }
    $2d-only-note
    { $matrix-scalar-note * }
}

{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 <identity-matrix> 3 m*n ."
        "{ { 3 0 0 } { 0 3 0 } { 0 0 3 } }"
    }
} ;

HELP: n/m
{ $values { "n" object } { "m" matrix }  }
{ $description "Every element in the input matrix " { $snippet "m" } " is divided by the scalar " { $snippet "n" } "." }
{ $notelist
    $keep-shape-note
    { $equiv-word-note "swapped" m/n }
    $2d-only-note
    { $matrix-scalar-note / }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "2 { { 4 5 } { 2 1 } } n/m ."
        "{ { 1/2 2/5 } { 1 2 } }"
    }
} ;

HELP: m/n
{ $values { "m" matrix } { "n" object } }
{ $description "Every element in the input matrix " { $snippet "m" } " is divided by the scalar " { $snippet "n" } "." }
{ $notelist
    $keep-shape-note
    { $equiv-word-note "swapped" n/m }
    $2d-only-note
    { $matrix-scalar-note / }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "{ { 4 5 } { 2 1 } } 2 m/n ."
        "{ { 2 2+1/2 } { 1 1/2 } }"
    }
} ;

HELP: m+
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Adds two matrices element-wise." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note + }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 2 3 } { 3 2 1 } } { { 4 5 6 } { 6 5 4 } } m+ ."
        "{ { 5 7 9 } { 9 7 5 } }"
    }
} ;

HELP: m-
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Subtracts two matrices element-wise." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note - }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 4 5 6 } { 6 5 4 } } { { 1 2 3 } { 3 2 1 } } m- ."
        "{ { 3 3 3 } { 3 3 3 } }"
    }
} ;

HELP: m*
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Multiplies two matrices element-wise." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note * }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m* ."
        "{ { 15 18 } { 60 153 } }"
    }
} ;

HELP: m/
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Divides two matrices element-wise." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note / }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m/ ."
        "{ { 1+2/3 4+1/2 } { 3+3/4 1+8/9 } }"
    }
} ;

HELP: mdotv
{ $values { "m" matrix } { "v" sequence } { "p" matrix } }
{ $description "Computes the dot product of a matrix and a vector." }
{ $notelist
    { $equiv-word-note "swapped" vdotm }
    $2d-only-note
    { $matrix-scalar-note * + }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 -1 2 } { 0 -3 1 } } { 2 1 0 } mdotv ."
        "{ 1 -3 }"
    }
} ;

HELP: vdotm
{ $values { "v" sequence } { "m" matrix } { "p" matrix } }
{ $description "Computes the dot product of a vector and a matrix." }
{ $notelist
    { $equiv-word-note "swapped" mdotv }
    $2d-only-note
    { $matrix-scalar-note * + }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 1 0 } { { 1 -1 2 } { 0 -3 1 } } vdotm ."
        "{ 2 -5 5 }"
    }
} ;

HELP: mdot
{ $values { "m" matrix } }
{ $description "Computes the dot product of two matrices, i.e multiplies them." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note * + }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 -1 2 } { 0 -3 1 } } { { 3 7 } { 9 12 } } mdot ."
        "{ { -6 -5 } { -27 -36 } }"
    }
} ;

HELP: m~
{ $values { "m1" matrix } { "m2" matrix } { "epsilon" number } { "?" boolean } }
{ $description "Compares the matrices like " { $link ~ } ", using the " { $snippet "epsilon" } "." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note ~ }
}
{ $examples
    { "In the example, only " { $snippet ".01" } " was added to each element, so the new matrix is within the epsilon " { $snippet ".1" } "of the original." }
    { $example
        "USING: kernel math math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } dup [ .01 + ] matrix-map .1 m~ ."
        "t"
    }
} ;

HELP: mmin
{ $values { "m" matrix } { "n" object } }
{ $description "Determine the minimum value of the matrix." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note min }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mmin ."
        "5"
    }
} ;

HELP: mmax
{ $values { "m" matrix } { "n" object } }
{ $description "Determine the maximum value of the matrix." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note max }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mmax ."
        "17"
    }
} ;

{ l2-norm frobenius-norm hilbert-schmidt-norm } related-words

HELP: matrix-l1-norm
{ $values { "m" matrix } { "n" number } }
{ $description "Find the norm (size) of a matrix in  𝑙₁ (" { $snippet "L^₁" } ") vector space, usually written ∥･∥₁."
$nl "This is the matrix norm when " { $snippet "p=1" } ", and is the overall maximum of the sums of the columns." }
{ $notelist
    { "User code should call the generic " { $link l1-norm } " instead." }
    { $equiv-word-note "matrix-specific" l1-norm }
    { $equiv-word-note { $snippet "p = 1" } matrix-p-norm }
    { $equiv-word-note "transpose" matrix-l-infinity-norm }
    $2d-only-note
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 2 -2 1 } { 1 3 -1 } { 2 -4 2 } } matrix-l1-norm ."
        "9"
    }
} ;

HELP: matrix-l2-norm
{ $values { "m" matrix } { "n" number } }
{ $description "Find the norm (size) of a matrix in 𝑙₂ (" { $snippet "L^2" } ") vector space, usually written ∥･∥₂."
$nl "This is the matrix norm when " { $snippet "p=2" } ", and is the square root of the sums of the squares of all the elements of the matrix." }
{ $notelist
    { "This norm is sometimes called the Hilbert-Schmidt norm." }
    { "User code should call the generic " { $link p-norm } " instead." }
    { $equiv-word-note "matrix-specific" l2-norm }
    { $equiv-word-note { $snippet "p = 2" } matrix-p-norm }
    { $equiv-word-note "transpose" l1-norm }
    $2d-only-note
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 1 } { 1 1 } } matrix-l2-norm ."
        "2.0"
    }
} ;

HELP: matrix-l-infinity-norm
{ $values { "m" matrix } { "n" number } }
{ $description "Find the norm (size) of a matrix, in 𝑙∞ (" { $snippet "L^∞" } ") vector space, usually written ∥･∥∞."
$nl "This is the matrix norm when " { $snippet "p=∞" } ", and is the overall maximum of the sums of the rows." }
{ $notelist
    { "User code should call the generic " { $link l1-norm } " instead." }
    { $equiv-word-note "matrix-specific" l-infinity-norm }
    { $equiv-word-note { $snippet "p = ∞" } matrix-p-norm }
    { $equiv-word-note "transpose" matrix-l1-norm }
    $2d-only-note
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 2 -2 1 } { 1 3 -1 } { 2 -4 2 } } matrix-l-infinity-norm ."
        "8"
    }
} ;

HELP: matrix-p-q-norm
{ $values { "m" matrix } { "p" "a positive real number" } { "q" "a positive real number" } { "n" "a non-negative real number" } }
{ $description "Find the norm (size) of a matrix in " { $snippet "L^p,q" } " vector space."
$nl "This is the matrix norm for any " { $snippet "p, q ∈ ℝ" } ". It is still an entry-wise norm, like " { $link matrix-p-norm-entrywise } ", and is not an induced or Schatten norm." }
{ $examples
    "Equivalent to " { $link l2-norm } " for " { $snippet "p = q = 2 " } ":"
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 1 } { 1 1 } } 2 2 matrix-p-q-norm ."
        "2.0"
    }
} ;

HELP: matrix-p-norm-entrywise
{ $values { "m" matrix } { "p" "a positive real number" } { "n" "a non-negative real number" } }
{ $description "Find the entry-wise norm of a matrix, in 𝑙ₚ (" { $snippet "L^p" } ") vector space."  }
{ $notes "This word is not an induced or Schatten norm, and it is distinct from all of " { $links matrix-l1-norm matrix-l2-norm matrix-l-infinity-norm } "." }
{ $examples
    { $example
       "USING: math.matrices prettyprint ;"
       "4 4 1 <matrix> 2 matrix-p-norm-entrywise ."
       "4.0"
    }
} ;

HELP: matrix-p-norm
{ $values { "m" matrix } { "p" "a positive real number" } { "n" "a non-negative real number" } }
{ $description "Find the norm (size) of a matrix in 𝑙ₚ (" { $snippet "L^p" } ") vector space, usually written ∥･∥ₚ. For " { $snippet "p ≠ 1, 2, ∞" } ", this is an \"entry-wise\" norm." }
{ $notelist
    { "User code should call the generic " { $link p-norm } " instead." }
    { $equiv-word-note "matrix-specific" p-norm }
    { $equiv-word-note { $snippet "p = q" } matrix-p-q-norm }
    $2d-only-note
}
{ $examples
   "Calls " { $link l1-norm } ":"
    { $example
       "USING: math.matrices prettyprint ;"
       "4 4 1 <matrix> 1 matrix-p-norm ."
       "4"
    }
   "Falls back to " { $link matrix-p-norm-entrywise } ":"
    { $example
       "USING: math.functions math.matrices prettyprint ;"
       "2 2 3 <matrix> 1.5 matrix-p-norm 7.559 10e-4 ~ ."
       "t"
    }
} ;

{ matrix-p-norm matrix-p-norm-entrywise } related-words
{ matrix-l1-norm matrix-l2-norm matrix-l-infinity-norm matrix-p-norm matrix-p-q-norm } related-words

HELP: matrix-normalize
{ $values { "m" "a matrix with at least 1 non-zero number" } { "m'" matrix } }
{ $description "Normalize a matrix containing at least 1 non-zero element. Each element from the input matrix is computed as a fraction of the maximum element. The maximum element becomes " { $snippet "1/1" } "." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note max abs / }
}
{ $examples
    { $example
       "USING: math.matrices prettyprint ;"
       "{ { 5 9 } { 15 17 } } matrix-normalize ."
       "{ { 5/17 9/17 } { 15/17 1 } }"
    }
} ;

HELP: main-diagonal
{ $values { "matrix" matrix } { "seq" sequence } }
{ $description "Find the main diagonal of a matrix." $nl "This diagonal begins in the upper left of the matrix at index " { $snippet "{ 0 0 }" } ", continuing downward and rightward for all indices " { $snippet "{ n n }" } " in the " { $link square-matrix } " subset of the input (see " { $link <square-rows> } ")." }
{ $notelist
    { "If the number of rows in the square subset of the input is even, then this diagonal will not contain elements found in the " { $link anti-diagonal } ". However, if the size of the square subset is odd, then this diagonal will share at most one element with " { $link anti-diagonal } "." }
    { "This diagonal is sometimes called the " { $emphasis "first diagonal" } "." }
    { $equiv-word-note "opposite" anti-diagonal }
}
{ $examples
    { "The operation is simple on a " { $link square-matrix } ":" }
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 7 2 11 }
    { 9 7 7 }
    { 1 8 0 }
} main-diagonal ."
        "{ 7 7 0 }"
    }
    "The square subset of the following input matrix consists of all rows but the last. The main diagonal does not include the last row because it has no fourth element."
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 6 5 0 }
    { 7 2 6 }
    { 4 3 9 }
    { 3 3 3 }
} main-diagonal ."
        "{ 6 2 9 }"
    }
} ;

HELP: anti-diagonal
{ $values { "matrix" matrix } { "seq" sequence } }
{ $description "Find the anti-diagonal of a matrix." $nl "This diagonal begins in the upper right of the matrix, continuing downward and leftward for all indices in the " { $link square-matrix } " subset of the input (see " { $link <square-rows> } ")." }
{ $notelist
    { "If the number of rows in the square subset of the input is even, then this diagonal will not contain elements found in the " { $link main-diagonal } ". However, if the size of the square subset is odd, then this diagonal will share at most one element with " { $link main-diagonal } "." }
    { "This diagonal is sometimes called the " { $emphasis "second diagonal" } "." }
    { $equiv-word-note "opposite" main-diagonal }
}
{ $examples
    { "The operation is simple on a " { $link square-matrix } ":" }
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 7 2 11 }
    { 9 7 7 }
    { 1 8 0 }
} anti-diagonal ."
        "{ 11 7 1 }"
    }
    "The square subset of the following input matrix consists of all rows but the last. The anti-diagonal does not include the last row because it has no fourth element."
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 6 5 0 }
    { 7 2 6 }
    { 4 3 9 }
    { 3 3 3 }
} anti-diagonal ."
        "{ 0 2 4 }"
    }
} ;


HELP: transpose
{ $values { "matrix" matrix } { "newmatrix" matrix } }
{ $description "Transpose the input matrix over its " { $link main-diagonal } ". The main diagonal itself is preserved, whereas the anti-diagonal is reversed." }
{ $notelist
    { "This word is an alias for " { $link flip } ", so that it may be recognised as the common mathematical operation." }
    { $equiv-word-note "opposite" anti-transpose }
}
{ $examples
    { $example
        "USING: math.matrices sequences prettyprint ;"
        "5 <iota> <anti-diagonal-matrix> transpose ."
"{
    { 0 0 0 0 4 }
    { 0 0 0 3 0 }
    { 0 0 2 0 0 }
    { 0 1 0 0 0 }
    { 0 0 0 0 0 }
}"
    }
} ;

HELP: anti-transpose
{ $values { "matrix" matrix } { "newmatrix" matrix } }
{ $description "Like " { $link transpose } " except that the matrix is transposed over the " { $link anti-diagonal } ", so that the anti-diagonal itself is preserved and the " { $link main-diagonal } " is reversed." }
{ $notes { $equiv-word-note "opposite" transpose } }
{ $examples
    { $example
        "USING: math.matrices sequences prettyprint ;"
        "5 <iota> <diagonal-matrix> anti-transpose ."
"{
    { 4 0 0 0 0 }
    { 0 3 0 0 0 }
    { 0 0 2 0 0 }
    { 0 0 0 1 0 }
    { 0 0 0 0 0 }
}"
    }
} ;

HELP: rows-except
{ $values { "matrix" matrix } { "desc" { $or integer sequence } } { "others" matrix } }
{ $contract "Get all the rows from " { $snippet "matrix" } " " { $emphasis "not" } " described by " { $snippet "desc" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 2 7 12 2 }
    { 8 9 10 0 }
    { 1 3 3 5 }
    { 8 13 7 12 }
} { 1 3 } rows-except ."
        "{ { 2 7 12 2 } { 1 3 3 5 } }"
    }
} ;

HELP: cols-except
{ $values { "matrix" matrix } { "desc" { $or integer sequence } } { "others" matrix } }
{ $contract "Get all the columns from " { $snippet "matrix" } " " { $emphasis "not" } " described by " { $snippet "desc" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 2 7 12 2 }
    { 8 9 10 0 }
    { 1 3 3 5 }
    { 8 13 7 12 }
} { 1 3 } cols-except . "
        "{ { 2 12 } { 8 10 } { 1 3 } { 8 7 } }"
    }
} ;
HELP: matrix-except
{ $values { "matrix" matrix } { "exclude-pair" pair } { "submatrix" matrix } }
{ $description "Get all the rows and columns from " { $snippet "matrix" } " except the row and column given in " { $snippet "exclude-pair" } ". The result is the " { $snippet "submatrix" } " containing no values from the given row and column." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 0 1 } { 2 3 } } { 0 1 } matrix-except ."
        "{ { 2 } }"
    }
} ;

HELP: submatrix-excluding
{ $values { "matrix" matrix } { "exclude-pair" pair } { "submatrix" matrix } }
{ $description "A possibly more obvious word for " { $link matrix-except } "." } ;

HELP: matrix-except-all
{ $values { "matrix" matrix } { "submatrices" { $sequence matrix } } }
{ $description "Find every possible submatrix of " { $snippet "matrix" } " by using " { $link matrix-except } " for every value's row-column pair." }
{ $examples
    "There are 9 possible 2x2 submatrices of a 3x3 matrix with 9 indices, because there are 9 indices to exclude creating a new submatrix."
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 0 1 2 } { 3 4 5 } { 6 7 8 } } matrix-except-all ."
        "{
    {
        { { 4 5 } { 7 8 } }
        { { 3 5 } { 6 8 } }
        { { 3 4 } { 6 7 } }
    }
    {
        { { 1 2 } { 7 8 } }
        { { 0 2 } { 6 8 } }
        { { 0 1 } { 6 7 } }
    }
    {
        { { 1 2 } { 4 5 } }
        { { 0 2 } { 3 5 } }
        { { 0 1 } { 3 4 } }
    }
}"
    }
} ;

HELP: all-submatrices
{ $values { "matrix" matrix } { "submatrices" { $sequence matrix } } }
{ $description "A possibly more obvious name for " { $link matrix-except-all } "." } ;

HELP: dimension
{ $values { "matrix" matrix } { "dimension" pair } }
{ $description "Find the dimension of the input matrix, in the order of " { $snippet "{ rows cols }" } "." }
{ $notelist $2d-only-note "Not to be confused with dimensionality, or the number of dimension scalars needed to describe a matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 30 1 <matrix> dimension ."
        "{ 4 30 }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "{ } dimension ."
        "{ 0 0 }"
    }
} ;
