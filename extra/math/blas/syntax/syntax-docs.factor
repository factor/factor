USING: help.markup help.syntax math.blas.matrices math.blas.vectors multiline ;
IN: math.blas.syntax

ARTICLE: "math.blas.syntax" "BLAS interface literal syntax"
"Vectors:"
{ $subsection POSTPONE: svector{ }
{ $subsection POSTPONE: dvector{ }
{ $subsection POSTPONE: cvector{ }
{ $subsection POSTPONE: zvector{ }
"Matrices:"
{ $subsection POSTPONE: smatrix{ }
{ $subsection POSTPONE: dmatrix{ }
{ $subsection POSTPONE: cmatrix{ }
{ $subsection POSTPONE: zmatrix{ } ;

ABOUT: "math.blas.syntax"

HELP: svector{
{ $syntax "svector{ 1.0 -2.0 3.0 }" }
{ $description "Construct a literal " { $link float-blas-vector } "." } ;

HELP: dvector{
{ $syntax "dvector{ 1.0 -2.0 3.0 }" }
{ $description "Construct a literal " { $link double-blas-vector } "." } ;

HELP: cvector{
{ $syntax "cvector{ 1.0 -2.0 C{ 3.0 -1.0 } }" }
{ $description "Construct a literal " { $link float-complex-blas-vector } "." } ;

HELP: zvector{
{ $syntax "dvector{ 1.0 -2.0 C{ 3.0 -1.0 } }" }
{ $description "Construct a literal " { $link double-complex-blas-vector } "." } ;

{
    POSTPONE: svector{ POSTPONE: dvector{
    POSTPONE: cvector{ POSTPONE: zvector{
} related-words

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
{ $description "Construct a literal " { $link float-complex-blas-matrix } ". Note that although BLAS matrices are stored in column-major order, the literal is specified in row-major order." } ;

HELP: zmatrix{
{ $syntax <" zmatrix{
    { 1.0 0.0           0.0 1.0           }
    { 0.0 C{ 0.0 1.0 }  0.0 2.0           }
    { 0.0 0.0          -1.0 3.0           }
    { 0.0 0.0           0.0 C{ 0.0 -1.0 } }
} "> }
{ $description "Construct a literal " { $link double-complex-blas-matrix } ". Note that although BLAS matrices are stored in column-major order, the literal is specified in row-major order." } ;

{
    POSTPONE: smatrix{ POSTPONE: dmatrix{
    POSTPONE: cmatrix{ POSTPONE: zmatrix{
} related-words
