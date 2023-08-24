! Copyright (C) 2019 HMC Clinic.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax lexer math sequences ;
IN: tensors

ARTICLE: "tensors" "Tensors"
"A " { $snippet "tensor" } " is a sequence of floating point numbers "
"shaped into an n-dimensional matrix. It supports fast, scalable matrix "
"operations such as matrix multiplication and transposition as well as a "
"number of element-wise operations. Words for working with tensors are found "
"in the " { $vocab-link "tensors" } " vocabulary." $nl
"More information about tensors can be found here:"
{ $subsections "creation" "manipulation" } ;

ARTICLE: "creation" "Creating Tensors"
"Tensors can be created by calling one of following constructors:"
{ $subsections zeros ones naturals arange (tensor) }
"They can be converted to/from the corresponding N-dimensional array with"
{ $subsections tensor>array >tensor }
"There is also a tensor parsing word"
{ $subsections POSTPONE: t{ } ;

ARTICLE: "manipulation" "Manipulating Tensors"
"The number of dimensions can be extracted with:"
{ $subsections dims }
"Tensors can be reshaped with:"
{ $subsections reshape flatten }
"Tensors can be combined element-wise with other tensors as well as numbers with:"
{ $subsections t+ t- t* t/ t% }
"Tensors support the following matrix operations:"
{ $subsections matmul transpose }
"Tensors also support the following concatenation operations:"
{ $subsections stack hstack vstack t-concat }
"Tensors implement all " { $vocab-link "sequences" } " operations." $nl
"Tensors can be indexed into using either numbers or arrays, for example:"
{ $example
    "USING: prettyprint sequences tensors ;"
    "t{ { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } }"
    "[ { 1 1 } swap nth ] [ 4 swap nth ] bi = ."
    "t"
}
"If the array being used to index into the tensor has the wrong number "
"of dimensions, a " { $link dimension-mismatch-error } " will be thrown." ;

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

HELP: non-uniform-seq-error
{ $values { "seq" sequence } }
{ $description "Throws a " { $link non-uniform-seq-error } "." }
{ $error-description "Thrown by operations such as " { $link >tensor } 
", which allow users to directly input the values of a " { $link tensor }
" as a nested sequence, when the subsequences have varying lengths." } ;

HELP: dimension-mismatch-error
{ $values { "tensor-dim" number } { "index-dim" number } }
{ $description "Throws a " { $link dimension-mismatch-error } "." }
{ $error-description "Thrown by indexing operations such as " { $link nth }
" and " { $link set-nth } " if the array being used to index has a different number "
"of dimensions than the tensor." } ;

HELP: t{
{ $syntax "t{ elements... }" }
{ $values { "elements" "a list of numbers" } }
{ $description "Initializes a tensor with the given elements."
" Preserves the shape of nested sequences. Assumes uniformly nested sequences." } 
{ $errors "Throws a " { $link non-uniform-seq-error } " if the given "
"sequence have subsequences of varying lengths. Throws a " 
{ $link lexer-error } " if the given sequence is not uniformly nested." } ;

HELP: (tensor)
{ $values { "shape" sequence } { "tensor" tensor } }
{ $description "Creates a tensor with shape " { $snippet "shape" }
" containing uninitialized values. Allows non-positive shapes." } ;

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

HELP: >tensor
{ $values { "seq" sequence } { "tensor" tensor } }
{ $description "Turns a nested sequence " { $snippet "seq" } 
" into a tensor of the corresponding shape. Assumes a uniformly nested sequence." } 
{ $errors "Throws a " { $link non-uniform-seq-error } " if the given "
"sequence have subsequences of varying lengths. Throws a " 
{ $link lexer-error } " if the given sequence is not uniformly nested." } ;

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
{ $description "Performs n-dimensional matrix transposition on " { $snippet "tensor" } "." } ;

HELP: stack 
{ $values { "seq" sequence } { "tensor" tensor } } 
{ $description "Joins the sequences in " { $snippet "seq" } " along a new axis. "
{ $snippet "tensor" } " will have one more dimension than the arrays in " { $snippet "seq" } "." } 
{ $errors "Throws a " { $link shape-mismatch-error } " if the sequences in "
{ $snippet "seq" } " do not have the same shape." } ;


HELP: hstack 
{ $values { "seq" sequence } { "tensor" tensor } } 
{ $description "Joins the sequences in " { $snippet "seq" } " column-wise." }
{ $errors "Throws a " { $link shape-mismatch-error } " if the sequences in "
{ $snippet "seq" } " do not have the same shape along all but the second axis." } ;

HELP: vstack 
{ $values { "seq" sequence } { "tensor" tensor } } 
{ $description "Joins the sequences in " { $snippet "seq" } " row-wise." }
{ $errors "Throws a " { $link shape-mismatch-error } " if the sequences in "
{ $snippet "seq" } " do not have the same shape along all but the first axis." } ;

HELP: t-concat
{ $values { "seq" sequence } { "tensor" tensor } } 
{ $description "Joins the sequences in " { $snippet "seq" } " along the first axis." }
{ $errors "Throws a " { $link shape-mismatch-error } " if the sequences in "
{ $snippet "seq" } " do not have the same shape along all but the first axis." } ;


ABOUT: "tensors"
