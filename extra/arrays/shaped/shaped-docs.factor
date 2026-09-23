USING: help.markup help.syntax math quotations sequences ;
IN: arrays.shaped

HELP: ndim
{ $values { "array" { $or shaped-array sequence number } } { "n" integer } }
{ $description "Returns the number of dimensions of a shaped array or a rectangular nested sequence. Numbers have zero dimensions. An empty ordinary sequence has one dimension." } ;

HELP: output-shape
{ $values { "sa0" shaped-array } { "sa1" shaped-array } { "shape" sequence } }
{ $description "Returns the broadcast result shape, aligning trailing axes and treating missing leading axes as size one. Corresponding dimensions must be equal or one must be one. A zero dimension combined with one remains zero. Incompatible shapes raise shape-mismatch." } ;

HELP: broadcastable?
{ $values { "sa0" shaped-array } { "sa1" shaped-array } { "?" "a boolean" } }
{ $description "Tests whether two shapes can broadcast under the trailing-axis rules used by output-shape. This checks shapes without copying either array's elements. Elementwise addition, subtraction and multiplication use these rules." } ;

HELP: shaped-array>array
{ $values { "shaped-array" shaped-array } { "array" sequence } }
{ $description "Converts flat row-major storage to nested arrays. Empty inner dimensions retain their outer structure: shape { 2 0 } becomes two empty arrays. Dimensions following a zero-length axis cannot be represented in an ordinary nested array." } ;

HELP: shaped-bounds-check
{ $values { "seq" sequence } { "shaped" shaped-array } }
{ $description "Checks that coordinates contain exactly one integer per axis, with negative indices counted from the end. Returns normalized nonnegative coordinates. Invalid coordinates raise shaped-bounds-error. Element accessors require full coordinates; use shaped-slice-view for partial indexing and slicing." } ;

HELP: shaped+
{ $values { "a" { $or shaped-array sequence number } } { "b" { $or shaped-array sequence number } } { "c" shaped-array } }
{ $description "Adds elements using trailing-axis broadcasting. Corresponding dimensions must be equal or one must be one. Returns fresh storage without modifying either input; incompatible shapes raise shape-mismatch." } ;

HELP: shaped-
{ $values { "a" { $or shaped-array sequence number } } { "b" { $or shaped-array sequence number } } { "c" shaped-array } }
{ $description "Subtracts b from a elementwise using the broadcasting and storage rules of shaped+." } ;

HELP: shaped*.
{ $values { "a" { $or shaped-array sequence number } } { "b" { $or shaped-array sequence number } } { "c" shaped-array } }
{ $description "Multiplies elements using the broadcasting and storage rules of shaped+. This is elementwise multiplication, not matrix multiplication." } ;

HELP: reshape
{ $values { "array" { $or shaped-array sequence number } } { "shape" { $or sequence integer } } { "result" shaped-array } }
{ $description "Returns a new shaped object in row-major order without changing the input shape. A shape integer denotes a single axis. Exactly one -1 dimension may be inferred from the number of elements; other dimensions must be nonnegative integers. Inference with a zero known product is ambiguous and rejected. An empty shape requires exactly one element. Ordinary storage is shared; virtual storage, including slice and transpose views, is copied into row-major order. Shape metadata is copied." }
{ $examples { $example "USING: arrays.shaped accessors prettyprint ;" "{ 2 3 } increasing { 3 -1 } reshape shape>> ." "{ 3 2 }" } } ;

HELP: zeros
{ $values { "shape" sequence } { "shaped-array" shaped-array } }
{ $description "Creates an array of zeros with nonnegative integer dimensions. An empty shape creates a zero-rank scalar array with one element; a zero dimension creates an array with no elements." } ;

HELP: ones
{ $values { "shape" sequence } { "shaped-array" shaped-array } }
{ $description "Creates an array of ones, using the shape rules of zeros." } ;

HELP: >shaped-array
{ $values { "array" { $or shaped-array sequence number } } { "shaped-array" shaped-array } }
{ $description "Converts a rectangular nested sequence to flat row-major storage. A number becomes a zero-rank array with one element. A shaped array is returned unchanged." } ;

HELP: <shaped-slice>
{ $values { "start" { $or integer "f" } } { "stop" { $or integer "f" } } { "step" { $or integer "f" } } { "slice" shaped-slice } }
{ $description "Constructs a slice selector. Bounds are stop-exclusive and clipped to the axis; negative bounds count from its end. f selects the default bound, and an f step means one. Negative steps reverse traversal; a zero or noninteger step is rejected when the slice is applied. Omitted stop and explicit -1 differ for a negative step, as in Python slicing." } ;

HELP: shaped-slice-view
{ $values { "array" { $or shaped-array sequence number } } { "selectors" sequence } { "view" shaped-array } }
{ $description "Returns a writable view using one integer, shaped-slice, or f selector per selected axis. Integers remove an axis; f and omitted trailing selectors retain the whole axis. Negative indices and slice steps are supported. Writes through the view affect the source storage and vice versa. Nested ordinary sequences are first converted to owned flat storage. Advanced indexing, ellipsis, and new-axis selectors are not implemented." }
{ $examples { $example "USING: arrays arrays.shaped prettyprint ;" "{ 0 1 2 3 4 } f f -1 <shaped-slice> 1array shaped-slice-view shaped-array>array ." "{ 4 3 2 1 0 }" } } ;

HELP: shaped-permute
{ $values { "array" { $or shaped-array sequence number } } { "axes" sequence } { "view" shaped-array } }
{ $description "Returns a writable view with axes in the specified order. Each axis must occur exactly once; negative axis numbers count from the end. Element storage is shared, and shape metadata is copied." } ;

HELP: shaped-transpose
{ $values { "array" { $or shaped-array sequence number } } { "view" shaped-array } }
{ $description "Returns a writable view with the axis order reversed. For two dimensions this is a matrix transpose; for zero or one dimension the shape is unchanged." } ;

HELP: shaped-map!
{ $values { "sa" shaped-array } { "quot" quotation } }
{ $description "Applies the quotation to every element in place and returns the shaped array. For views, writes affect the source storage." } ;

HELP: shaped-sum
{ $values { "array" { $or shaped-array sequence number } } { "axes" { $or integer sequence "f" } } { "keepdims?" "a boolean" } { "result" shaped-array } }
{ $description "Sums over the specified axes. f selects all axes; an integer selects one axis; a sequence selects several, with an empty sequence selecting none. Negative axes count from the end; duplicates and invalid axes are rejected. With keepdims? true, reduced axes remain with size one. Returns fresh storage, including a zero-rank shaped array when all axes are removed. Empty sums are zero. Arithmetic uses Factor numeric types rather than NumPy dtype promotion." } ;

HELP: shaped-mean
{ $values { "array" { $or shaped-array sequence number } } { "axes" { $or integer sequence "f" } } { "keepdims?" "a boolean" } { "result" shaped-array } }
{ $description "Computes the arithmetic mean using the axis and result-shape rules of shaped-sum, dividing by a floating-point element count. Empty means are NaN. Unlike NumPy, this word does not emit a runtime warning for empty means." } ;

HELP: shaped-min
{ $values { "array" { $or shaped-array sequence number } } { "axes" { $or integer sequence "f" } } { "keepdims?" "a boolean" } { "result" shaped-array } }
{ $description "Computes minima using the axis rules of shaped-sum. NaNs propagate. Reducing over an empty axis raises empty-shaped-reduction; an empty result is permitted when only unreduced axes are empty." } ;

HELP: shaped-max
{ $values { "array" { $or shaped-array sequence number } } { "axes" { $or integer sequence "f" } } { "keepdims?" "a boolean" } { "result" shaped-array } }
{ $description "Computes maxima using the axis rules of shaped-sum and the empty-axis and NaN behavior of shaped-min." } ;

HELP: shaped-matmul
{ $values { "a" { $or shaped-array sequence } } { "b" { $or shaped-array sequence } } { "result" shaped-array } }
{ $description "Multiplies matrices on the final two axes and broadcasts leading batch axes. A left vector is promoted to a row, and a right vector to a column; the inserted axes are removed from the result. Two vectors produce a zero-rank dot product. Scalars and incompatible contraction dimensions are rejected. Empty contraction dimensions produce zeros. Inputs may be views; the result has fresh storage. This uses Factor arithmetic and does not conjugate complex inputs or call BLAS." }
{ $examples { $example "USING: arrays.shaped accessors prettyprint ;" "{ 1 2 3 } { 4 5 6 } shaped-matmul underlying>> ." "{ 32 }" } } ;

ARTICLE: "arrays.shaped.numpy" "NumPy-style shaped-array operations"
"Shaped arrays support broadcast elementwise arithmetic, scalar arrays, reshape, writable basic views, axis reductions, and batched matrix multiplication. They use Factor numbers and sequence storage; they do not implement NumPy's dtype system or its full API."
{ $subsections >shaped-array reshape shaped-slice-view shaped-permute shaped-transpose shaped-sum shaped-mean shaped-min shaped-max shaped-matmul }
"A shaped array is a flat sequence for Factor's sequence protocol: length is its total element count. Access shape for dimensions. Reduction and vector-dot results remain shaped arrays, with an empty shape for scalars. Ordinary reshape shares data but creates new shape metadata; reshaping a virtual view materializes its logical row-major elements. Basic views share data. Cloning copies storage and shape metadata; cloning a view materializes its logical row-major elements. Arithmetic and reductions allocate fresh output. "
"Zero-rank axis reductions use f or an empty axis sequence. Slicing currently excludes advanced indexing, ellipsis, and new-axis insertion. Numeric dtype selection, out/where/initial reduction arguments, Fortran-order reshape, and optimized BLAS kernels are outside this API." ;
