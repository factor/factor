USING: alien byte-arrays help.markup help.syntax sequences ;
IN: math.blas.vectors

HELP: blas-vector-base
{ $class-description "The base class for all BLAS vector types. Objects of this type should not be created directly; instead, instantiate one of the typed subclasses:"
{ $list
    { { $link float-blas-vector } }
    { { $link double-blas-vector } }
    { { $link float-complex-blas-vector } }
    { { $link double-complex-blas-vector } }
}
"All of these subclasses share the same tuple layout:"
{ $list
    { { $snippet "data" } " contains an alien pointer referencing or byte-array containing a packed array of float, double, float complex, or double complex values;" }
    { { $snippet "length" } " indicates the length of the vector;" }
    { "and " { $snippet "inc" } " indicates the distance, in elements, between elements." }
} } ;

HELP: float-blas-vector
{ $class-description "A vector of single-precision floating-point values. For details on the tuple layout, see " { $link blas-vector-base } "." } ;
HELP: double-blas-vector
{ $class-description "A vector of double-precision floating-point values. For details on the tuple layout, see " { $link blas-vector-base } "." } ;
HELP: float-complex-blas-vector
{ $class-description "A vector of single-precision floating-point complex values. Complex values are stored in memory as two consecutive float values, real part then imaginary part. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;
HELP: double-complex-blas-vector
{ $class-description "A vector of single-precision floating-point complex values. Complex values are stored in memory as two consecutive float values, real part then imaginary part. For details on the tuple layout, see " { $link blas-matrix-base } "." } ;

HELP: n*V+V-in-place
{ $values { "alpha" "a number" } { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } { "y" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the vector sum " { $snippet "αx + y" } " and replace the existing contents of y with the result. Corresponds to the xAXPY routines in BLAS." }
{ $side-effects "The memory used by y is overwritten with the result." } ;

HELP: n*V-in-place
{ $values { "alpha" "a number" } { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the scalar-vector product " { $snippet "αx" } " and replace the existing contents of x with the result. Corresponds to the xSCAL routines in BLAS." }
{ $side-effects "The memory used by x is overwritten with the result." } ;

HELP: V.
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } { "y" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the inner product " { $snippet "x⋅y" } ". Corresponds to the xDOT and xDOTU routines in BLAS." } ;

HELP: V.conj
{ $values { "x" "a complex BLAS vector inheriting from " { $link blas-vector-base } } { "y" "a complex BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the conjugate inner product " { $snippet "x̅⋅y" } ". Corresponds to the xDOTC routines in BLAS." } ;

HELP: Vnorm
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the norm-2, i.e., the magnitude or absolute value, of " { $snippet "x" } " (" { $snippet "‖x‖₂" } "). Corresponds to the xNRM2 routines in BLAS." } ;

HELP: Vasum
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the sum of the norm-1s of the elements of " { $snippet "x" } " (" { $snippet "Σ ‖xᵢ‖₁" } "). Corresponds to the xASUM routines in BLAS." } ;

HELP: Vswap
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } { "y" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Swap the contents of " { $snippet "x" } " and " { $snippet "y" } " in place. Corresponds to the xSWAP routines in BLAS." }
{ $side-effects "The memory contents of the two vectors are exchanged." } ;

HELP: Viamax
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Return the index of the element in " { $snippet "x" } " with the largest norm-1. If more than one element has the same norm-1, returns the smallest index. Corresponds to the IxAMAX routines in BLAS." } ;

HELP: Vamax
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Return the value of the element in " { $snippet "x" } " with the largest norm-1. If more than one element has the same norm-1, returns the first element. Corresponds to the IxAMAX routines in BLAS." } ;

{ Viamax Vamax } related-words

HELP: element-type
{ $values { "v" "a BLAS vector inheriting from " { $link blas-vector-base } ", or a BLAS matrix inheriting from " { $link blas-matrix-base } } }
{ $description "Return the C type of the elements in the given BLAS vector or matrix." } ;

HELP: <zero-vector>
{ $values { "exemplar" "a BLAS vector inheriting from " { $link blas-vector-base } " } }
{ $description "Return a vector of zeros with the same length and element type as " { $snippet "v" } ". The vector is constructed with an " { $snippet "inc" } " of zero, so it is not suitable for receiving results from BLAS functions; it is intended to be used as a term in other vector calculations. To construct an empty vector that can be used to receive results, see " { $link <empty-vector> } "." } ;

HELP: <empty-vector>
{ $values { "length" "The length of the new vector" } { "exemplar" "a BLAS vector inheriting from " { $link blas-vector-base } " } }
{ $description "Return a vector of zeros with the given length and the same element type as " { $snippet "v" } "." } ;

HELP: n*V+V
{ $values { "alpha" "a number" } { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } { "y" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the vector sum " { $snippet "αx + y" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " and " { $snippet "y" } " containing the result. Corresponds to the xAXPY routines in BLAS." } ;

HELP: n*V
{ $values { "alpha" "a number" } { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the scalar-vector product " { $snippet "αx" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " containing the result. Corresponds to the xSCAL routines in BLAS." } ;

HELP: V+
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } { "y" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the vector sum " { $snippet "x + y" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " and " { $snippet "y" } " containing the result. Corresponds to the xAXPY routines in BLAS." } ;

HELP: V-
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } { "y" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Calculate the vector difference " { $snippet "x – y" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " and " { $snippet "y" } " containing the result. Corresponds to the xAXPY routines in BLAS." } ;

HELP: Vneg
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } { "y" "a BLAS vector inheriting from " { $link blas-vector-base } } }
{ $description "Negate the elements of " { $snippet "x" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " and " { $snippet "y" } " containing the result." } ;

HELP: V*n
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } { "alpha" "a number" } }
{ $description "Calculate the scalar-vector product " { $snippet "αx" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " containing the result. Corresponds to the xSCAL routines in BLAS." } ;

HELP: V/n
{ $values { "x" "a BLAS vector inheriting from " { $link blas-vector-base } } { "alpha" "a number" } }
{ $description "Calculate the scalar-vector product " { $snippet "(1/α)x" } " and return a freshly-allocated vector with the same length as " { $snippet "x" } " containing the result. Corresponds to the xSCAL routines in BLAS." } ;

{ n*V+V-in-place n*V-in-place n*V+V n*V V+ V- Vneg V*n V/n } related-words


