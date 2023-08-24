USING: help.markup help.syntax math ;
IN: math.blas.vectors

ARTICLE: "math.blas.vectors" "BLAS interface vector operations"
"Slicing vectors:"
{ $subsections Vsub }
"Taking the norm (magnitude) of a vector:"
{ $subsections Vnorm }
"Summing and taking the maximum of elements:"
{ $subsections
    Vasum
    Viamax
    Vamax
}
"Scalar-vector products:"
{ $subsections
    n*V!
    n*V
    V*n
    V/n
    Vneg
}
"Vector addition:"
{ $subsections
    n*V+V!
    n*V+V
    V+
    V-
}
"Vector inner products:"
{ $subsections
    V.
    V.conj
}
"Literal syntax:"
{ $subsections
    POSTPONE: svector{
    POSTPONE: dvector{
    POSTPONE: cvector{
    POSTPONE: zvector{
} ;

ABOUT: "math.blas.vectors"

HELP: blas-vector-base
{ $class-description "The base class for all BLAS vector types. Objects of this type should not be created directly; instead, instantiate one of the typed subclasses:"
{ $list
    { { $link float-blas-vector } }
    { { $link double-blas-vector } }
    { { $link complex-float-blas-vector } }
    { { $link complex-double-blas-vector } }
}
"All of these subclasses share the same tuple layout:"
{ $list
    { { $snippet "underlying" } " contains an alien pointer referencing or byte-array containing a packed array of float, double, float complex, or double complex values;" }
    { { $snippet "length" } " indicates the length of the vector;" }
    { "and " { $snippet "inc" } " indicates the distance, in elements, between elements." }
} } ;

HELP: float-blas-vector
{ $class-description "A vector of single-precision floating-point values. For details on the tuple layout, see " { $link blas-vector-base } "." } ;
HELP: double-blas-vector
{ $class-description "A vector of double-precision floating-point values. For details on the tuple layout, see " { $link blas-vector-base } "." } ;
HELP: complex-float-blas-vector
{ $class-description "A vector of single-precision floating-point complex values. For details on the tuple layout, see " { $link blas-vector-base } "." } ;
HELP: complex-double-blas-vector
{ $class-description "A vector of double-precision floating-point complex values. For details on the tuple layout, see " { $link blas-vector-base } "." } ;

HELP: n*V+V!
{ $values { "alpha" number } { "x" blas-vector-base } { "y" blas-vector-base } { "y=alpha*x+y" blas-vector-base } }
{ $description "Calculate the vector sum " { $snippet "αx + y" } " and replace the existing contents of y with the result. Corresponds to the xAXPY routines in BLAS." }
{ $side-effects "y" } ;

HELP: n*V!
{ $values { "alpha" number } { "x" blas-vector-base } { "x=alpha*x" blas-vector-base } }
{ $description "Calculate the scalar-vector product " { $snippet "αx" } " and replace the existing contents of x with the result. Corresponds to the xSCAL routines in BLAS." }
{ $side-effects "x" } ;

HELP: V.
{ $values { "x" blas-vector-base } { "y" blas-vector-base } { "x.y" number } }
{ $description "Calculate the inner product " { $snippet "x⋅y" } ". Corresponds to the xDOT and xDOTU routines in BLAS." } ;

HELP: V.conj
{ $values { "x" blas-vector-base } { "y" blas-vector-base } { "xconj.y" number } }
{ $description "Calculate the conjugate inner product " { $snippet "x̅⋅y" } ". Corresponds to the xDOTC routines in BLAS." } ;

HELP: Vnorm
{ $values { "x" blas-vector-base } { "norm" number } }
{ $description "Calculate the norm-2, i.e., the magnitude or absolute value, of " { $snippet "x" } " (" { $snippet "‖x‖₂" } "). Corresponds to the xNRM2 routines in BLAS." } ;

HELP: Vasum
{ $values { "x" blas-vector-base } { "sum" number } }
{ $description "Calculate the sum of the norm-1s of the elements of " { $snippet "x" } " (" { $snippet "Σ ‖xᵢ‖₁" } "). Corresponds to the xASUM routines in BLAS." } ;

HELP: Vswap
{ $values { "x" blas-vector-base } { "y" blas-vector-base } { "x=y" blas-vector-base } { "y=x" blas-vector-base } }
{ $description "Swap the contents of " { $snippet "x" } " and " { $snippet "y" } " in place. Corresponds to the xSWAP routines in BLAS." }
{ $side-effects "x" "y" } ;

HELP: Viamax
{ $values { "x" blas-vector-base } { "max-i" integer } }
{ $description "Return the index of the element in " { $snippet "x" } " with the largest norm-1. If more than one element has the same norm-1, returns the smallest index. Corresponds to the IxAMAX routines in BLAS." } ;

HELP: Vamax
{ $values { "x" blas-vector-base } { "max" number } }
{ $description "Return the value of the element in " { $snippet "x" } " with the largest norm-1. If more than one element has the same norm-1, returns the element closest to the beginning. Corresponds to the IxAMAX routines in BLAS." } ;

{ Viamax Vamax } related-words

HELP: <zero-vector>
{ $values { "exemplar" blas-vector-base } { "zero" blas-vector-base } }
{ $description "Return a vector of zeros with the same length and element type as " { $snippet "v" } ". The vector is constructed with an " { $snippet "inc" } " of zero, so it is not suitable for receiving results from BLAS functions; it is intended to be used as a term in other vector calculations. To construct an empty vector that can be used to receive results, see " { $link <empty-vector> } "." } ;

HELP: n*V+V
{ $values { "alpha" number } { "x" blas-vector-base } { "y" blas-vector-base } { "alpha*x+y" blas-vector-base } }
{ $description "Calculate the vector sum " { $snippet "αx + y" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " and " { $snippet "y" } " containing the result. Corresponds to the xAXPY routines in BLAS." } ;

HELP: n*V
{ $values { "alpha" number } { "x" blas-vector-base } { "alpha*x" blas-vector-base } }
{ $description "Calculate the scalar-vector product " { $snippet "αx" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " containing the result. Corresponds to the xSCAL routines in BLAS." } ;

HELP: V+
{ $values { "x" blas-vector-base } { "y" blas-vector-base } { "x+y" blas-vector-base } }
{ $description "Calculate the vector sum " { $snippet "x + y" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " and " { $snippet "y" } " containing the result. Corresponds to the xAXPY routines in BLAS." } ;

HELP: V-
{ $values { "x" blas-vector-base } { "y" blas-vector-base } { "x-y" blas-vector-base } }
{ $description "Calculate the vector difference " { $snippet "x – y" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " and " { $snippet "y" } " containing the result. Corresponds to the xAXPY routines in BLAS." } ;

HELP: Vneg
{ $values { "x" blas-vector-base } { "-x" blas-vector-base } }
{ $description "Negate the elements of " { $snippet "x" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " containing the result." } ;

HELP: V*n
{ $values { "x" blas-vector-base } { "alpha" number } { "x*alpha" blas-vector-base } }
{ $description "Calculate the scalar-vector product " { $snippet "αx" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " containing the result. Corresponds to the xSCAL routines in BLAS." } ;

HELP: V/n
{ $values { "x" blas-vector-base } { "alpha" number } { "x/alpha" blas-vector-base } }
{ $description "Calculate the scalar-vector product " { $snippet "(1/α)x" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " containing the result. Corresponds to the xSCAL routines in BLAS." } ;

{ n*V+V! n*V! n*V+V n*V V+ V- Vneg V*n V/n } related-words

HELP: Vsub
{ $values { "v" blas-vector-base } { "start" integer } { "length" integer } { "sub" blas-vector-base } }
{ $description "Slice a subvector out of " { $snippet "v" } " starting at " { $snippet "start" } " with the given " { $snippet "length" } ". The subvector will share storage with the parent vector." } ;

HELP: svector{
{ $syntax "svector{ 1.0 -2.0 3.0 }" }
{ $description "Construct a literal " { $link float-blas-vector } "." } ;

HELP: dvector{
{ $syntax "dvector{ 1.0 -2.0 3.0 }" }
{ $description "Construct a literal " { $link double-blas-vector } "." } ;

HELP: cvector{
{ $syntax "cvector{ 1.0 -2.0 C{ 3.0 -1.0 } }" }
{ $description "Construct a literal " { $link complex-float-blas-vector } "." } ;

HELP: zvector{
{ $syntax "zvector{ 1.0 -2.0 C{ 3.0 -1.0 } }" }
{ $description "Construct a literal " { $link complex-double-blas-vector } "." } ;

{
    POSTPONE: svector{ POSTPONE: dvector{
    POSTPONE: cvector{ POSTPONE: zvector{
} related-words
