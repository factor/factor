USING: alien byte-arrays help.markup help.syntax math.blas.vectors sequences ;
IN: math.blas.matrices

ARTICLE: "math.blas-summary" "Basic Linear Algebra Subroutines (BLAS) interface"
"Factor provides an interface to high-performance vector and matrix math routines available in the system's BLAS library. A set of specialized types are provided for handling packed, unboxed vector data:"
{ $subsection "math.blas-types" }
"Scalar-vector and vector-vector operations are available in the " { $vocab-link "math.blas.vectors" } " vocabulary:"
{ $subsection "math.blas.vectors" }
"Vector-matrix and matrix-matrix operations are available in the " { $vocab-link "math.blas.matrices" } " vocabulary:"
{ $subsection "math.blas.matrices" }
"The low-level BLAS C interface can be accessed directly through the " { $vocab-link "math.blas.cblas" } " vocabulary." ;

ARTICLE: "math.blas-types" "BLAS interface types"
"BLAS vectors come in single- and double-precision, real and complex flavors:"
{ $subsection float-blas-vector }
{ $subsection double-blas-vector }
{ $subsection float-complex-blas-vector }
{ $subsection double-complex-blas-vector }
"These vector types all follow the " { $link sequence } " protocol. In addition, there are corresponding types for matrix data:"
{ $subsection float-blas-matrix }
{ $subsection double-blas-matrix }
{ $subsection float-complex-blas-matrix }
{ $subsection double-complex-blas-matrix } 
"Syntax words are provided for constructing literal vectors and matrices in the " { $vocab-link "math.blas.syntax" } " vocabulary:"
{ $subsection "math.blas.syntax" }
"There are BOA constructors for all vector and matrix types, which provide the most flexibility in specifying memory layout:"
{ $subsection <float-blas-vector> }
{ $subsection <double-blas-vector> }
{ $subsection <float-complex-blas-vector> }
{ $subsection <double-complex-blas-vector> }
{ $subsection <float-blas-matrix> }
{ $subsection <double-blas-matrix> }
{ $subsection <float-complex-blas-matrix> }
{ $subsection <double-complex-blas-matrix> }
"For the simple case of creating a dense, zero-filled vector or matrix, simple empty object constructors are provided:"
{ $subsection <empty-vector> }
{ $subsection <empty-matrix> } ;

ARTICLE: "math.blas.matrices" "BLAS interface matrix operations"
"Transposing and slicing matrices:"
{ $subsection Mtranspose }
{ $subsection Mrows }
{ $subsection Mcols }
{ $subsection Msub }
"Matrix-vector products:"
{ $subsection n*M.V+n*V-in-place }
{ $subsection n*M.V+n*V }
{ $subsection n*M.V }
{ $subsection M.V }
"Vector outer products:"
{ $subsection n*V(*)V+M-in-place }
{ $subsection n*V(*)Vconj+M-in-place }
{ $subsection n*V(*)V+M }
{ $subsection n*V(*)Vconj+M }
{ $subsection n*V(*)V }
{ $subsection n*V(*)Vconj }
{ $subsection V(*) }
{ $subsection V(*)conj }
"Matrix products:"
{ $subsection n*M.M+n*M-in-place }
{ $subsection n*M.M+n*M }
{ $subsection n*M.M }
{ $subsection M. }
"Scalar-matrix products:"
{ $subsection n*M-in-place }
{ $subsection n*M }
{ $subsection M*n }
{ $subsection M/n } ;

ABOUT: "math.blas.matrices"

HELP: blas-matrix-base
{ $class-description "The base class for all BLAS matrix types. Objects of this type should not be created directly; instead, instantiate one of the typed subclasses:"
{ $list
    { { $link float-blas-matrix } }
    { { $link double-blas-matrix } }
    { { $link float-complex-blas-matrix } }
    { { $link double-complex-blas-matrix } }
}
"All of these subclasses share the same tuple layout:"
{ $list
    { { $snippet "data" } " contains an alien pointer referencing or byte-array containing a packed, column-major array of float, double, float complex, or double complex values;" }
    { { $snippet "ld" } " indicates the distance, in elements, between matrix columns;" }
    { { $snippet "rows" } " and " { $snippet "cols" } " indicate the number of significant rows and columns in the matrix;" }
    { "and " { $snippet "transpose" } ", if set to a true value, indicates that the matrix should be treated as transposed relative to its in-memory representation." }
} } ;

{ blas-vector-base blas-matrix-base } related-words

HELP: float-blas-matrix
{ $class-description "A matrix of single-precision floating-point values. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;
HELP: double-blas-matrix
{ $class-description "A matrix of double-precision floating-point values. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;
HELP: float-complex-blas-matrix
{ $class-description "A matrix of single-precision floating-point complex values. Complex values are stored in memory as two consecutive float values, real part then imaginary part. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;
HELP: double-complex-blas-matrix
{ $class-description "A matrix of double-precision floating-point complex values. Complex values are stored in memory as two consecutive float values, real part then imaginary part. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;

{
    float-blas-matrix double-blas-matrix float-complex-blas-matrix double-complex-blas-matrix
    float-blas-vector double-blas-vector float-complex-blas-vector double-complex-blas-vector
} related-words

HELP: Mwidth
{ $values { "matrix" "a BLAS matrix inherited from " { $link blas-matrix-base } } { "width" "The number of columns" } }
{ $description "Returns the number of columns in " { $snippet "matrix" } "." } ;

HELP: Mheight
{ $values { "matrix" "a BLAS matrix inherited from " { $link blas-matrix-base } } { "width" "The number of columns" } }
{ $description "Returns the number of rows in " { $snippet "matrix" } "." } ;

{ Mwidth Mheight } related-words

HELP: n*M.V+n*V-in-place
{ $values { "alpha" "a number" } { "A" "an M-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } { "x" "an N-element BLAS vector inherited from " { $link blas-vector-base } } { "beta" "a number" } { "y" "an M-element BLAS vector inherited from " { $link blas-vector-base } } }
{ $description "Calculate the matrix-vector product " { $snippet "αAx + βy" } ", and overwrite the current contents of " { $snippet "y" } " with the result. The width of " { $snippet "A" } " must match the length of " { $snippet "x" } ", and the height must match the length of " { $snippet "y" } ". Corresponds to the xGEMV routines in BLAS." }
{ $side-effects "y" } ;

HELP: n*V(*)V+M-in-place
{ $values { "alpha" "a number" } { "x" "an M-element BLAS vector inherited from " { $link blas-vector-base } } { "y" "an N-element BLAS vector inherited from " { $link blas-vector-base } } { "A" "an M-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } }
{ $description "Calculate the outer product " { $snippet "αx⊗y + A" } " and overwrite the current contents of A with the result. The width of " { $snippet "A" } " must match the length of " { $snippet "y" } ", and its height must match the length of " { $snippet "x" } ". Corresponds to the xGER and xGERU routines in BLAS." }
{ $side-effects "A" } ;

HELP: n*V(*)Vconj+M-in-place
{ $values { "alpha" "a number" } { "x" "an M-element complex BLAS vector inherited from " { $link blas-vector-base } } { "y" "an N-element complex BLAS vector inherited from " { $link blas-vector-base } } { "A" "an M-row, N-column complex BLAS matrix inherited from " { $link blas-matrix-base } } }
{ $description "Calculate the conjugate outer product " { $snippet "αx⊗y̅ + A" } " and overwrite the current contents of A with the result. The width of " { $snippet "A" } " must match the length of " { $snippet "y" } ", and its height must match the length of " { $snippet "x" } ". Corresponds to the xGERC routines in BLAS." }
{ $side-effects "A" } ;

HELP: n*M.M+n*M-in-place
{ $values { "alpha" "a number" } { "A" "an M-row, K-column BLAS matrix inherited from " { $link blas-matrix-base } } { "B" "a K-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } { "beta" "a number" } { "C" "an M-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } }
{ $description "Calculate the matrix product " { $snippet "αAB + βC" } " and overwrite the current contents of C with the result. The width of " { $snippet "A" } " and the height of " { $snippet "B" } " must match, as must the heights of " { $snippet "A" } " and " { $snippet "C" } ", and the widths of " { $snippet "B" } " and " { $snippet "C" } ". Corresponds to the xGEMM routines in BLAS." } ;

HELP: <empty-matrix>
{ $values { "rows" "the number of rows the new matrix will have" } { "cols" "the number of columns the new matrix will have" } { "exemplar" "A BLAS vector inherited from " { $link blas-vector-base } " or BLAS matrix inherited from " { $link blas-matrix-base } } }
{ $description "Create a matrix of all zeros with the given dimensions and the same element type as " { $snippet "exemplar" } "." } ;

{ <zero-vector> <empty-vector> <empty-matrix> } related-words

HELP: n*M.V+n*V
{ $values { "alpha" "a number" } { "A" "an M-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } { "x" "an N-element BLAS vector inherited from " { $link blas-vector-base } } { "beta" "a number" } { "y" "an M-element BLAS vector inherited from " { $link blas-vector-base } } }
{ $description "Calculate the matrix-vector product " { $snippet "αAx + βy" } " and return a freshly allocated vector containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "x" } ", and the height must match the length of " { $snippet "y" } ". The returned vector will have the same length as " { $snippet "y" } ". Corresponds to the xGEMV routines in BLAS." } ;

HELP: n*V(*)V+M
{ $values { "alpha" "a number" } { "x" "an M-element BLAS vector inherited from " { $link blas-vector-base } } { "y" "an N-element BLAS vector inherited from " { $link blas-vector-base } } { "A" "an M-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } }
{ $description "Calculate the outer product " { $snippet "αx⊗y + A" } " and return a freshly allocated matrix containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "y" } ", and its height must match the length of " { $snippet "x" } ". The returned matrix will have the same dimensions as " { $snippet "A" } ". Corresponds to the xGER and xGERU routines in BLAS." } ;

HELP: n*V(*)Vconj+M
{ $values { "alpha" "a number" } { "x" "an M-element complex BLAS vector inherited from " { $link blas-vector-base } } { "y" "an N-element complex BLAS vector inherited from " { $link blas-vector-base } } { "A" "an M-row, N-column complex BLAS matrix inherited from " { $link blas-matrix-base } } }
{ $description "Calculate the conjugate outer product " { $snippet "αx⊗y̅ + A" } " and return a freshly allocated matrix containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "y" } ", and its height must match the length of " { $snippet "x" } ". The returned matrix will have the same dimensions as " { $snippet "A" } ". Corresponds to the xGERC routines in BLAS." } ;

HELP: n*M.M+n*M
{ $values { "alpha" "a number" } { "A" "an M-row, K-column BLAS matrix inherited from " { $link blas-matrix-base } } { "B" "a K-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } { "beta" "a number" } { "C" "an M-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } }
{ $description "Calculate the matrix product " { $snippet "αAB + βC" } " and overwrite the current contents of C with the result. The width of " { $snippet "A" } " and the height of " { $snippet "B" } " must match, as must the heights of " { $snippet "A" } " and " { $snippet "C" } ", and the widths of " { $snippet "B" } " and " { $snippet "C" } ". Corresponds to the xGEMM routines in BLAS." } ;

HELP: n*M.V
{ $values { "alpha" "a number" } { "A" "an M-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } { "x" "an N-element BLAS vector inherited from " { $link blas-vector-base } } }
{ $description "Calculate the matrix-vector product " { $snippet "αAx" } " and return a freshly allocated vector containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "x" } ". The length of the returned vector will match the height of " { $snippet "A" } ". Corresponds to the xGEMV routines in BLAS." } ;

HELP: M.V
{ $values { "A" "an M-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } { "x" "an N-element BLAS vector inherited from " { $link blas-vector-base } } }
{ $description "Calculate the matrix-vector product " { $snippet "Ax" } " and return a freshly allocated vector containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "x" } ". The length of the returned vector will match the height of " { $snippet "A" } ". Corresponds to the xGEMV routines in BLAS." } ;

{ n*M.V+n*V-in-place n*M.V+n*V n*M.V M.V } related-words

HELP: n*V(*)V
{ $values { "alpha" "a number" } { "x" "an M-element BLAS vector inherited from " { $link blas-vector-base } } { "y" "an N-element BLAS vector inherited from " { $link blas-vector-base } } }
{ $description "Calculate the outer product " { $snippet "αx⊗y" } " and return a freshly allocated matrix containing the result. The returned matrix's height will match the length of " { $snippet "x" } ", and its width will match the length of " { $snippet "y" } ". Corresponds to the xGER and xGERU routines in BLAS." } ;

HELP: n*V(*)Vconj
{ $values { "alpha" "a number" } { "x" "an M-element BLAS vector inherited from " { $link blas-vector-base } } { "y" "an N-element BLAS vector inherited from " { $link blas-vector-base } } }
{ $description "Calculate the outer product " { $snippet "αx⊗y̅" } " and return a freshly allocated matrix containing the result. The returned matrix's height will match the length of " { $snippet "x" } ", and its width will match the length of " { $snippet "y" } ". Corresponds to the xGERC routines in BLAS." } ;

HELP: V(*)
{ $values { "x" "an M-element BLAS vector inherited from " { $link blas-vector-base } } { "y" "an N-element BLAS vector inherited from " { $link blas-vector-base } } }
{ $description "Calculate the outer product " { $snippet "x⊗y" } " and return a freshly allocated matrix containing the result. The returned matrix's height will match the length of " { $snippet "x" } ", and its width will match the length of " { $snippet "y" } ". Corresponds to the xGER and xGERU routines in BLAS." } ;

HELP: V(*)conj
{ $values { "x" "an M-element BLAS vector inherited from " { $link blas-vector-base } } { "y" "an N-element BLAS vector inherited from " { $link blas-vector-base } } }
{ $description "Calculate the conjugate outer product " { $snippet "x⊗y̅" } " and return a freshly allocated matrix containing the result. The returned matrix's height will match the length of " { $snippet "x" } ", and its width will match the length of " { $snippet "y" } ". Corresponds to the xGERC routines in BLAS." } ;

{ n*V(*)V+M-in-place n*V(*)Vconj+M-in-place n*V(*)V+M n*V(*)Vconj+M n*V(*)V n*V(*)Vconj V(*) V(*)conj V. V.conj } related-words

HELP: n*M.M
{ $values { "alpha" "a number" } { "A" "an M-row, K-column BLAS matrix inherited from " { $link blas-matrix-base } } { "B" "a K-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } }
{ $description "Calculate the matrix product " { $snippet "αAB" } " and return a freshly allocated matrix containing the result. The width of " { $snippet "A" } " and the height of " { $snippet "B" } " must match. The returned matrix's height will be the same as " { $snippet "A" } "'s, and its width will match " { $snippet "B" } "'s. Corresponds to the xGEMM routines in BLAS." } ;

HELP: M.
{ $values { "A" "an M-row, K-column BLAS matrix inherited from " { $link blas-matrix-base } } { "B" "a K-row, N-column BLAS matrix inherited from " { $link blas-matrix-base } } }
{ $description "Calculate the matrix product " { $snippet "AB" } " and return a freshly allocated matrix containing the result. The width of " { $snippet "A" } " and the height of " { $snippet "B" } " must match. The returned matrix's height will be the same as " { $snippet "A" } "'s, and its width will match " { $snippet "B" } "'s. Corresponds to the xGEMM routines in BLAS." } ;

{ n*M.M+n*M-in-place n*M.M+n*M n*M.M M. } related-words

HELP: Msub
{ $values { "matrix" "A BLAS matrix inheriting from " { $link blas-matrix-base } } { "row" "The topmost row of the slice" } { "col" "The leftmost column of the slice" } { "height" "The height of the slice" } { "width" "The width of the slice" } }
{ $description "Select a rectangular submatrix of " { $snippet "matrix" } " with the given dimensions. The returned submatrix will share the parent matrix's storage." } ;

HELP: Mrows
{ $values { "matrix" "A BLAS matrix inheriting from " { $link blas-matrix-base } } }
{ $description "Return a sequence of BLAS vectors representing the rows of " { $snippet "matrix" } ". Each vector will share the parent matrix's storage." } ;

HELP: Mcols
{ $values { "matrix" "A BLAS matrix inheriting from " { $link blas-matrix-base } } }
{ $description "Return a sequence of BLAS vectors representing the columns of " { $snippet "matrix" } ". Each vector will share the parent matrix's storage." } ;

HELP: n*M-in-place
{ $values { "n" "a number" } { "A" "A BLAS matrix inheriting from " { $link blas-matrix-base } } }
{ $description "Calculate the scalar-matrix product " { $snippet "nA" } " and overwrite the current contents of A with the result." }
{ $side-effects "A" } ;

HELP: n*M
{ $values { "n" "a number" } { "A" "A BLAS matrix inheriting from " { $link blas-matrix-base } } }
{ $description "Calculate the scalar-matrix product " { $snippet "nA" } " and return a freshly allocated matrix with the same dimensions as " { $snippet "A" } " containing the result." } ;

HELP: M*n
{ $values { "A" "A BLAS matrix inheriting from " { $link blas-matrix-base } } { "n" "a number" } }
{ $description "Calculate the scalar-matrix product " { $snippet "nA" } " and return a freshly allocated matrix with the same dimensions as " { $snippet "A" } " containing the result." } ;

HELP: M/n
{ $values { "A" "A BLAS matrix inheriting from " { $link blas-matrix-base } } { "n" "a number" } }
{ $description "Calculate the scalar-matrix product " { $snippet "(1/n)A" } " and return a freshly allocated matrix with the same dimensions as " { $snippet "A" } " containing the result." } ;

{ n*M-in-place n*M M*n M/n } related-words

HELP: Mtranspose
{ $values { "matrix" "A BLAS matrix inheriting from " { $link blas-matrix-base } } }
{ $description "Returns the transpose of " { $snippet "matrix" } ". The returned matrix shares storage with the original matrix." } ;

HELP: element-type
{ $values { "v" "a BLAS vector inheriting from " { $link blas-vector-base } ", or a BLAS matrix inheriting from " { $link blas-matrix-base } } }
{ $description "Return the C type of the elements in the given BLAS vector or matrix." } ;

HELP: <empty-vector>
{ $values { "length" "The length of the new vector" } { "exemplar" "a BLAS vector inheriting from " { $link blas-vector-base } ", or a BLAS matrix inheriting from " { $link blas-matrix-base } } }
{ $description "Return a vector of zeros with the given length and the same element type as " { $snippet "v" } "." } ;

