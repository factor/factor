! Copyright (C) 2019 HMC Clinic.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax math sequences ;
IN: tensors

ARTICLE: "tensors" "Tensors" "A " { $snippet "tensor" } " is a sequence "
"of floating point numbers "
"shaped into an n-dimensional matrix. It supports fast, scalable matrix "
"operations such as matrix multiplication and transposition as well as a "
"number of element-wise operations. Words for working with tensors are found "
"in the " { $vocab-link "tensors" } " vocabulary." $nl $nl
"Tensors can be created "
"by calling one of four constructors:"
{ $subsections zeros ones naturals arange }
"They can be converted to the corresponding N-dimensional array with"
{ $subsections tensor>array }
"The number of dimensions can be extracted with:"
{ $subsections dims }
"Additionally, tensors can be reshaped with:"
{ $subsections reshape flatten }
"Tensors can be combined element-wise with other tensors as well as numbers with:"
{ $subsections t+ t- t* t/ t% }
"Finally, tensors support the following matrix operations:"
{ $subsections matmul transpose } ;

ARTICLE: "tensor-operators" "Tensor Operators" "Info here" ;

HELP: tensor
{ $class-description "A sequence of floating-point numbers consisting of an "
{ $snippet "underlying" } " C-style array and a " { $snippet "shape" } "." } ;

HELP: shape-mismatch-error
{ $values { "shape1" sequence } { "shape2" sequence } }
{ $description "Throws a " { $link shape-mismatch-error } "." }
{ $error-description "Thrown by element-wise operations such as " { $link t+ }
", " { $link t- } ", " { $link t* } ", " { $link t/ } ", and " { $link t% }
" as well as matrix operations such as " { $link matmul } " if two tensors are "
"passed and they cannot be combined as desired because of a difference in the "
"shape." } ;

HELP: non-positive-shape-error
{ $values { "shape" sequence } }
{ $description "Throws a " { $link non-positive-shape-error } "." }
{ $error-description "Thrown by operations such as " { $link zeros } ", "
{ $link ones } ", " { $link naturals } ", and " { $link reshape }
", which allow users to directly set the shape of a " { $link tensor }
", when the shape has zero or negative values." } ;

HELP: zeros
{ $values { "shape" sequence } { "tensor" tensor } }
{ $description "Initializes a tensor with shape " { $snippet "shape" }
" containing all 0s." }
{ $errors "Throws a " { $link non-positive-shape-error } " if the given "
"shape has zero or negative values." } ;

HELP: ones
{ $values { "shape" sequence } { "tensor" tensor } }
{ $description "Initializes a tensor with shape " { $snippet "shape" }
" containing all 1s." }
{ $errors "Throws a " { $link non-positive-shape-error } " if the given "
"shape has zero or negative values." } ;

HELP: arange
{ $values { "a" number } { "b" number } { "step" number } { "tensor" tensor } }
{ $description "Initializes a one-dimensional tensor with values in a range from "
    { $snippet "a" } " to " { $snippet "b" } " (inclusive) with step-size " { $snippet "step" } "." } ;

HELP: naturals
{ $values { "shape" sequence } { "tensor" tensor } }
{ $description "Initializes a tensor with shape " { $snippet "shape" }
" containing a range of values from 0 to " { $snippet "shape product" } "." }
{ $errors "Throws a " { $link non-positive-shape-error } " if the given "
"shape has zero or negative values." } ;

HELP: reshape
{ $values { "tensor" tensor } { "shape" sequence } }
{ $description "Reshapes " { $snippet "tensor" } " to have shape "
{ $snippet "shape" } "." }
{ $errors "Throws a " { $link non-positive-shape-error } " if the given "
"shape has zero or negative values." } ;

HELP: flatten
{ $values { "tensor" tensor } }
{ $description "Reshapes " { $snippet "tensor" } " so that it is one-dimensional." } ;

HELP: dims
{ $values { "tensor" tensor } { "n" integer } }
{ $description "Returns the dimension of " { $snippet "tensor" } "." } ;

HELP: t+
{ $values { "x" { $or tensor number } } { "y" { $or tensor number } } { "tensor" tensor } }
{ $description "Element-wise addition. Intakes two tensors or a tensor and a number (in either order)." }
{ $errors "Throws a " { $link shape-mismatch-error } " if passed two tensors that are "
"not (or cannot be broadcast to be) the same shape." } ;

HELP: t-
{ $values { "x" { $or tensor number } } { "y" { $or tensor number } } { "tensor" tensor } }
{ $description "Element-wise subtraction. Intakes two tensors or a tensor and a number (in either order)." }
{ $errors "Throws a " { $link shape-mismatch-error } " if passed two tensors that are "
"not (or cannot be broadcast to be) the same shape." } ;

HELP: t*
{ $values { "x" { $or tensor number } } { "y" { $or tensor number } } { "tensor" tensor } }
{ $description "Element-wise multiplication. Intakes two tensors or a tensor and a number (in either order)." }
{ $errors "Throws a " { $link shape-mismatch-error } " if passed two tensors that are "
"not (or cannot be broadcast to be) the same shape." } ;

HELP: t/
{ $values { "x" { $or tensor number } } { "y" { $or tensor number } } { "tensor" tensor } }
{ $description "Element-wise division. Intakes two tensors or a tensor and a number (in either order)." }
{ $errors "Throws a " { $link shape-mismatch-error } " if passed two tensors that are "
"not (or cannot be broadcast to be) the same shape." } ;

HELP: t%
{ $values { "x" { $or tensor number } } { "y" { $or tensor number } } { "tensor" tensor } }
{ $description "Element-wise modulo operator. Intakes two tensors or a tensor and a number (in either order)." }
{ $errors "Throws a " { $link shape-mismatch-error } " if passed two tensors that are "
"not (or cannot be broadcast to be) the same shape." } ;

HELP: tensor>array
{ $values { "tensor" tensor } { "seq" array } }
{ $description "Returns " { $snippet "tensor" } " as an n-dimensional array." } ;

HELP: matmul
{ $values { "tensor1" tensor } { "tensor2" tensor } { "tensor3" tensor } }
{ $description "Performs n-dimensional matrix multiplication on two tensors, where " { $snippet "tensor1" }
    " has shape " { $snippet "...xmxn" } " and " { $snippet "tensor1" } " has shape " { $snippet "...xnxp" } "." }
{ $errors "Throws a " { $link shape-mismatch-error } " if the bottom two "
"dimensions of the tensors passed do not take the form " { $snippet "mxn" }
" and " { $snippet "nxp" } " and/or the top dimensions do not match." } ;

HELP: transpose
{ $values { "tensor" tensor } { "tensor'" tensor } }
{ $description "Performs n-dimensional matrix transposition on " { $snippet "tens" } "." } ;

ABOUT: "tensors"
