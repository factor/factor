USING: help.markup help.syntax math sequences ;
IN: arrays.shaped

HELP: ndim
{ $values { "array" { $or shaped-array sequence } } { "n" integer } }
{ $description "Returns the number of dimensions of a shaped array or a rectangular nested sequence. An empty ordinary sequence has one dimension." } ;

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
{ $description "Checks that coordinates contain exactly one nonnegative integer per axis, each less than its dimension. Invalid coordinates raise shaped-bounds-error. These element accessors require full coordinates and do not implement NumPy slicing or negative indexing." } ;

HELP: shaped+
{ $values { "a" { $or shaped-array sequence } } { "b" { $or shaped-array sequence } } { "c" shaped-array } }
{ $description "Adds elements using trailing-axis broadcasting. Corresponding dimensions must be equal or one must be one. Returns fresh storage without modifying either input; incompatible shapes raise shape-mismatch." } ;

HELP: shaped-
{ $values { "a" { $or shaped-array sequence } } { "b" { $or shaped-array sequence } } { "c" shaped-array } }
{ $description "Subtracts b from a elementwise using the broadcasting and storage rules of shaped+." } ;

HELP: shaped*.
{ $values { "a" { $or shaped-array sequence } } { "b" { $or shaped-array sequence } } { "c" shaped-array } }
{ $description "Multiplies elements using the broadcasting and storage rules of shaped+. This is elementwise multiplication, not matrix multiplication." } ;
