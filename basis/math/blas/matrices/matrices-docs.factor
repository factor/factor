USING: alien byte-arrays help.markup help.syntax math math.blas.vectors sequences strings multiline ;
IN: math.blas.matrices

ARTICLE: "math.blas-summary" "Basic Linear Algebra Subroutines (BLAS) interface"
"Factor provides an interface to high-performance vector and matrix math routines available in implementations of the BLAS math library. A set of specialized types are provided for handling packed, unboxed vector data:"
{ $subsection "math.blas-types" }
"Scalar-vector and vector-vector operations are available in the " { $vocab-link "math.blas.vectors" } " vocabulary:"
{ $subsection "math.blas.vectors" }
"Vector-matrix and matrix-matrix operations are available in the " { $vocab-link "math.blas.matrices" } " vocabulary:"
{ $subsection "math.blas.matrices" }
"The low-level BLAS Fortran interface can be accessed directly through the " { $vocab-link "math.blas.ffi" } " vocabulary. The BLAS interface can be configured to use different underlying BLAS implementations:"
{ $subsection "math.blas.config" } ;

ARTICLE: "math.blas-types" "BLAS interface types"
"BLAS vectors come in single- and double-precision, real and complex flavors:"
{ $subsection float-blas-vector }
{ $subsection double-blas-vector }
{ $subsection complex-float-blas-vector }
{ $subsection complex-double-blas-vector }
"These vector types all follow the " { $link sequence } " protocol. In addition, there are corresponding types for matrix data:"
{ $subsection float-blas-matrix }
{ $subsection double-blas-matrix }
{ $subsection complex-float-blas-matrix }
{ $subsection complex-double-blas-matrix } 
"There are BOA constructors for all vector and matrix types, which provide the most flexibility in specifying memory layout:"
{ $subsection <float-blas-vector> }
{ $subsection <double-blas-vector> }
{ $subsection <complex-float-blas-vector> }
{ $subsection <complex-double-blas-vector> }
{ $subsection <float-blas-matrix> }
{ $subsection <double-blas-matrix> }
{ $subsection <complex-float-blas-matrix> }
{ $subsection <complex-double-blas-matrix> }
"For the simple case of creating a dense, zero-filled vector or matrix, simple empty object constructors are provided:"
{ $subsection <empty-vector> }
{ $subsection <empty-matrix> }
"BLAS vectors and matrices can also be constructed from other Factor sequences:"
{ $subsection >float-blas-vector }
{ $subsection >double-blas-vector }
{ $subsection >complex-float-blas-vector }
{ $subsection >complex-double-blas-vector }
{ $subsection >float-blas-matrix }
{ $subsection >double-blas-matrix }
{ $subsection >complex-float-blas-matrix }
{ $subsection >complex-double-blas-matrix } ;

ARTICLE: "math.blas.matrices" "BLAS interface matrix operations"
"Transposing and slicing matrices:"
{ $subsection Mtranspose }
{ $subsection Mrows }
{ $subsection Mcols }
{ $subsection Msub }
"Matrix-vector products:"
{ $subsection n*M.V+n*V! }
{ $subsection n*M.V+n*V }
{ $subsection n*M.V }
{ $subsection M.V }
"Vector outer products:"
{ $subsection n*V(*)V+M! }
{ $subsection n*V(*)Vconj+M! }
{ $subsection n*V(*)V+M }
{ $subsection n*V(*)Vconj+M }
{ $subsection n*V(*)V }
{ $subsection n*V(*)Vconj }
{ $subsection V(*) }
{ $subsection V(*)conj }
"Matrix products:"
{ $subsection n*M.M+n*M! }
{ $subsection n*M.M+n*M }
{ $subsection n*M.M }
{ $subsection M. }
"Scalar-matrix products:"
{ $subsection n*M! }
{ $subsection n*M }
{ $subsection M*n }
{ $subsection M/n }
"Literal syntax:"
{ $subsection POSTPONE: smatrix{ }
{ $subsection POSTPONE: dmatrix{ }
{ $subsection POSTPONE: cmatrix{ }
{ $subsection POSTPONE: zmatrix{ } ;


ABOUT: "math.blas.matrices"

HELP: blas-matrix-base
{ $class-description "The base class for all BLAS matrix types. Objects of this type should not be created directly; instead, instantiate one of the typed subclasses:"
{ $list
    { { $link float-blas-matrix } }
    { { $link double-blas-matrix } }
    { { $link complex-float-blas-matrix } }
    { { $link complex-double-blas-matrix } }
}
"All of these subclasses share the same tuple layout:"
{ $list
    { { $snippet "underlying" } " contains an alien pointer referencing or byte-array containing a packed, column-major array of float, double, float complex, or double complex values;" }
    { { $snippet "ld" } " indicates the distance, in elements, between matrix columns;" }
    { { $snippet "rows" } " and " { $snippet "cols" } " indicate the number of significant rows and columns in the matrix;" }
    { "and " { $snippet "transpose" } ", if set to a true value, indicates that the matrix should be treated as transposed relative to its in-memory representation." }
} } ;

{ blas-vector-base blas-matrix-base } related-words

HELP: float-blas-matrix
{ $class-description "A matrix of single-precision floating-point values. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;
HELP: double-blas-matrix
{ $class-description "A matrix of double-precision floating-point values. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;
HELP: complex-float-blas-matrix
{ $class-description "A matrix of single-precision floating-point complex values. Complex values are stored in memory as two consecutive float values, real part then imaginary part. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;
HELP: complex-double-blas-matrix
{ $class-description "A matrix of double-precision floating-point complex values. Complex values are stored in memory as two consecutive float values, real part then imaginary part. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;

{
    float-blas-matrix double-blas-matrix complex-float-blas-matrix complex-double-blas-matrix
    float-blas-vector double-blas-vector complex-float-blas-vector complex-double-blas-vector
} related-words

HELP: Mwidth
{ $values { "matrix" blas-matrix-base } { "width" integer } }
{ $description "Returns the number of columns in " { $snippet "matrix" } "." } ;

HELP: Mheight
{ $values { "matrix" blas-matrix-base } { "height" integer } }
{ $description "Returns the number of rows in " { $snippet "matrix" } "." } ;

{ Mwidth Mheight } related-words

HELP: n*M.V+n*V!
{ $values { "alpha" number } { "A" blas-matrix-base } { "x" blas-vector-base } { "beta" number } { "y" blas-vector-base } { "y=alpha*A.x+b*y" blas-vector-base } }
{ $description "Calculate the matrix-vector product " { $snippet "αAx + βy" } ", and overwrite the current contents of " { $snippet "y" } " with the result. The width of " { $snippet "A" } " must match the length of " { $snippet "x" } ", and the height must match the length of " { $snippet "y" } ". Corresponds to the xGEMV routines in BLAS." }
{ $side-effects "y" } ;

HELP: n*V(*)V+M!
{ $values { "alpha" number } { "x" blas-vector-base } { "y" blas-vector-base } { "A" blas-matrix-base } { "A=alpha*x(*)y+A" blas-matrix-base } }
{ $description "Calculate the outer product " { $snippet "αx⊗y + A" } " and overwrite the current contents of A with the result. The width of " { $snippet "A" } " must match the length of " { $snippet "y" } ", and its height must match the length of " { $snippet "x" } ". Corresponds to the xGER and xGERU routines in BLAS." }
{ $side-effects "A" } ;

HELP: n*V(*)Vconj+M!
{ $values { "alpha" number } { "x" blas-vector-base } { "y" blas-vector-base } { "A" blas-matrix-base } { "A=alpha*x(*)yconj+A" blas-matrix-base } }
{ $description "Calculate the conjugate outer product " { $snippet "αx⊗y̅ + A" } " and overwrite the current contents of A with the result. The width of " { $snippet "A" } " must match the length of " { $snippet "y" } ", and its height must match the length of " { $snippet "x" } ". Corresponds to the xGERC routines in BLAS." }
{ $side-effects "A" } ;

HELP: n*M.M+n*M!
{ $values { "alpha" number } { "A" blas-matrix-base } { "B" blas-matrix-base } { "beta" number } { "C" blas-matrix-base } { "C=alpha*A.B+beta*C" blas-matrix-base } }
{ $description "Calculate the matrix product " { $snippet "αAB + βC" } " and overwrite the current contents of C with the result. The width of " { $snippet "A" } " and the height of " { $snippet "B" } " must match, as must the heights of " { $snippet "A" } " and " { $snippet "C" } ", and the widths of " { $snippet "B" } " and " { $snippet "C" } ". Corresponds to the xGEMM routines in BLAS." }
{ $side-effects "C" } ;

HELP: <empty-matrix>
{ $values { "rows" integer } { "cols" integer } { "exemplar" blas-vector-base blas-matrix-base } { "matrix" blas-matrix-base } }
{ $description "Create a matrix of all zeros with the given dimensions and the same element type as " { $snippet "exemplar" } "." } ;

{ <zero-vector> <empty-vector> <empty-matrix> } related-words

HELP: n*M.V+n*V
{ $values { "alpha" number } { "A" blas-matrix-base } { "x" blas-vector-base } { "beta" number } { "y" blas-vector-base } { "alpha*A.x+b*y" blas-vector-base } }
{ $description "Calculate the matrix-vector product " { $snippet "αAx + βy" } " and return a freshly allocated vector containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "x" } ", and the height must match the length of " { $snippet "y" } ". The returned vector will have the same length as " { $snippet "y" } ". Corresponds to the xGEMV routines in BLAS." } ;

HELP: n*V(*)V+M
{ $values { "alpha" number } { "x" blas-vector-base } { "y" blas-vector-base } { "A" blas-matrix-base } { "alpha*x(*)y+A" blas-matrix-base } }
{ $description "Calculate the outer product " { $snippet "αx⊗y + A" } " and return a freshly allocated matrix containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "y" } ", and its height must match the length of " { $snippet "x" } ". The returned matrix will have the same dimensions as " { $snippet "A" } ". Corresponds to the xGER and xGERU routines in BLAS." } ;

HELP: n*V(*)Vconj+M
{ $values { "alpha" number } { "x" blas-vector-base } { "y" blas-vector-base } { "A" blas-matrix-base } { "alpha*x(*)yconj+A" blas-matrix-base } }
{ $description "Calculate the conjugate outer product " { $snippet "αx⊗y̅ + A" } " and return a freshly allocated matrix containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "y" } ", and its height must match the length of " { $snippet "x" } ". The returned matrix will have the same dimensions as " { $snippet "A" } ". Corresponds to the xGERC routines in BLAS." } ;

HELP: n*M.M+n*M
{ $values { "alpha" number } { "A" blas-matrix-base } { "B" blas-matrix-base } { "beta" number } { "C" blas-matrix-base } { "alpha*A.B+beta*C" blas-matrix-base } }
{ $description "Calculate the matrix product " { $snippet "αAB + βC" } " and overwrite the current contents of C with the result. The width of " { $snippet "A" } " and the height of " { $snippet "B" } " must match, as must the heights of " { $snippet "A" } " and " { $snippet "C" } ", and the widths of " { $snippet "B" } " and " { $snippet "C" } ". Corresponds to the xGEMM routines in BLAS." } ;

HELP: n*M.V
{ $values { "alpha" number } { "A" blas-matrix-base } { "x" blas-vector-base } { "alpha*A.x" blas-vector-base } }
{ $description "Calculate the matrix-vector product " { $snippet "αAx" } " and return a freshly allocated vector containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "x" } ". The length of the returned vector will match the height of " { $snippet "A" } ". Corresponds to the xGEMV routines in BLAS." } ;

HELP: M.V
{ $values { "A" blas-matrix-base } { "x" blas-vector-base } { "A.x" blas-vector-base } }
{ $description "Calculate the matrix-vector product " { $snippet "Ax" } " and return a freshly allocated vector containing the result. The width of " { $snippet "A" } " must match the length of " { $snippet "x" } ". The length of the returned vector will match the height of " { $snippet "A" } ". Corresponds to the xGEMV routines in BLAS." } ;

{ n*M.V+n*V! n*M.V+n*V n*M.V M.V } related-words

HELP: n*V(*)V
{ $values { "alpha" number } { "x" blas-vector-base } { "y" blas-vector-base } { "alpha*x(*)y" blas-matrix-base } }
{ $description "Calculate the outer product " { $snippet "αx⊗y" } " and return a freshly allocated matrix containing the result. The returned matrix's height will match the length of " { $snippet "x" } ", and its width will match the length of " { $snippet "y" } ". Corresponds to the xGER and xGERU routines in BLAS." } ;

HELP: n*V(*)Vconj
{ $values { "alpha" number } { "x" blas-vector-base } { "y" blas-vector-base } { "alpha*x(*)yconj" blas-matrix-base } }
{ $description "Calculate the outer product " { $snippet "αx⊗y̅" } " and return a freshly allocated matrix containing the result. The returned matrix's height will match the length of " { $snippet "x" } ", and its width will match the length of " { $snippet "y" } ". Corresponds to the xGERC routines in BLAS." } ;

HELP: V(*)
{ $values { "x" blas-vector-base } { "y" blas-vector-base } { "x(*)y" blas-matrix-base } }
{ $description "Calculate the outer product " { $snippet "x⊗y" } " and return a freshly allocated matrix containing the result. The returned matrix's height will match the length of " { $snippet "x" } ", and its width will match the length of " { $snippet "y" } ". Corresponds to the xGER and xGERU routines in BLAS." } ;

HELP: V(*)conj
{ $values { "x" blas-vector-base } { "y" blas-vector-base } { "x(*)yconj" blas-matrix-base } }
{ $description "Calculate the conjugate outer product " { $snippet "x⊗y̅" } " and return a freshly allocated matrix containing the result. The returned matrix's height will match the length of " { $snippet "x" } ", and its width will match the length of " { $snippet "y" } ". Corresponds to the xGERC routines in BLAS." } ;

{ n*V(*)V+M! n*V(*)Vconj+M! n*V(*)V+M n*V(*)Vconj+M n*V(*)V n*V(*)Vconj V(*) V(*)conj V. V.conj } related-words

HELP: n*M.M
{ $values { "alpha" number } { "A" blas-matrix-base } { "B" blas-matrix-base } { "alpha*A.B" blas-matrix-base } }
{ $description "Calculate the matrix product " { $snippet "αAB" } " and return a freshly allocated matrix containing the result. The width of " { $snippet "A" } " and the height of " { $snippet "B" } " must match. The returned matrix's height will be the same as " { $snippet "A" } "'s, and its width will match " { $snippet "B" } "'s. Corresponds to the xGEMM routines in BLAS." } ;

HELP: M.
{ $values { "A" blas-matrix-base } { "B" blas-matrix-base } { "A.B" blas-matrix-base } }
{ $description "Calculate the matrix product " { $snippet "AB" } " and return a freshly allocated matrix containing the result. The width of " { $snippet "A" } " and the height of " { $snippet "B" } " must match. The returned matrix's height will be the same as " { $snippet "A" } "'s, and its width will match " { $snippet "B" } "'s. Corresponds to the xGEMM routines in BLAS." } ;

{ n*M.M+n*M! n*M.M+n*M n*M.M M. } related-words

HELP: Msub
{ $values { "matrix" blas-matrix-base } { "row" integer } { "col" integer } { "height" integer } { "width" integer } { "sub" blas-matrix-base } }
{ $description "Select a rectangular submatrix of " { $snippet "matrix" } " with the given dimensions. The returned submatrix will share the parent matrix's storage." } ;

HELP: Mrows
{ $values { "A" blas-matrix-base } { "rows" sequence } }
{ $description "Return a sequence of BLAS vectors representing the rows of " { $snippet "matrix" } ". Each vector will share the parent matrix's storage." } ;

HELP: Mcols
{ $values { "A" blas-matrix-base } { "cols" sequence } }
{ $description "Return a sequence of BLAS vectors representing the columns of " { $snippet "matrix" } ". Each vector will share the parent matrix's storage." } ;

HELP: n*M!
{ $values { "n" number } { "A" blas-matrix-base } { "A=n*A" blas-matrix-base } }
{ $description "Calculate the scalar-matrix product " { $snippet "nA" } " and overwrite the current contents of A with the result." }
{ $side-effects "A" } ;

HELP: n*M
{ $values { "n" number } { "A" blas-matrix-base } { "n*A" blas-matrix-base } }
{ $description "Calculate the scalar-matrix product " { $snippet "nA" } " and return a freshly allocated matrix with the same dimensions as " { $snippet "A" } " containing the result." } ;

HELP: M*n
{ $values { "A" blas-matrix-base } { "n" number } { "A*n" blas-matrix-base } }
{ $description "Calculate the scalar-matrix product " { $snippet "nA" } " and return a freshly allocated matrix with the same dimensions as " { $snippet "A" } " containing the result." } ;

HELP: M/n
{ $values { "A" blas-matrix-base } { "n" number } { "A/n" blas-matrix-base } }
{ $description "Calculate the scalar-matrix product " { $snippet "(1/n)A" } " and return a freshly allocated matrix with the same dimensions as " { $snippet "A" } " containing the result." } ;

{ n*M! n*M M*n M/n } related-words

HELP: Mtranspose
{ $values { "matrix" blas-matrix-base } { "matrix^T" blas-matrix-base } }
{ $description "Returns the transpose of " { $snippet "matrix" } ". The returned matrix shares storage with the original matrix." } ;

HELP: element-type
{ $values { "v" blas-vector-base blas-matrix-base } { "type" string } }
{ $description "Return the C type of the elements in the given BLAS vector or matrix." } ;

HELP: <empty-vector>
{ $values { "length" "The length of the new vector" } { "exemplar" blas-vector-base blas-matrix-base } { "vector" blas-vector-base } }
{ $description "Return a vector of zeros with the given " { $snippet "length" } " and the same element type as " { $snippet "v" } "." } ;

HELP: smatrix{
{ $syntax <" smatrix{
    { 1.0 0.0 0.0 1.0 }
    { 0.0 1.0 0.0 2.0 }
    { 0.0 0.0 1.0 3.0 }
    { 0.0 0.0 0.0 1.0 }
} "> }
{ $description "Construct a literal " { $link float-blas-matrix } ". Note that although BLAS matrices are stored in column-major order, the literal is specified in row-major order." } ;

HELP: dmatrix{
{ $syntax <" dmatrix{
    { 1.0 0.0 0.0 1.0 }
    { 0.0 1.0 0.0 2.0 }
    { 0.0 0.0 1.0 3.0 }
    { 0.0 0.0 0.0 1.0 }
} "> }
{ $description "Construct a literal " { $link double-blas-matrix } ". Note that although BLAS matrices are stored in column-major order, the literal is specified in row-major order." } ;

HELP: cmatrix{
{ $syntax <" cmatrix{
    { 1.0 0.0           0.0 1.0           }
    { 0.0 C{ 0.0 1.0 }  0.0 2.0           }
    { 0.0 0.0          -1.0 3.0           }
    { 0.0 0.0           0.0 C{ 0.0 -1.0 } }
} "> }
{ $description "Construct a literal " { $link complex-float-blas-matrix } ". Note that although BLAS matrices are stored in column-major order, the literal is specified in row-major order." } ;

HELP: zmatrix{
{ $syntax <" zmatrix{
    { 1.0 0.0           0.0 1.0           }
    { 0.0 C{ 0.0 1.0 }  0.0 2.0           }
    { 0.0 0.0          -1.0 3.0           }
    { 0.0 0.0           0.0 C{ 0.0 -1.0 } }
} "> }
{ $description "Construct a literal " { $link complex-double-blas-matrix } ". Note that although BLAS matrices are stored in column-major order, the literal is specified in row-major order." } ;

{
    POSTPONE: smatrix{ POSTPONE: dmatrix{
    POSTPONE: cmatrix{ POSTPONE: zmatrix{
} related-words
