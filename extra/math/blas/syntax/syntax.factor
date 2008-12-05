USING: kernel math.blas.vectors math.blas.matrices parser
arrays prettyprint.backend sequences ;
IN: math.blas.syntax

: svector{
    \ } [ >float-blas-vector ] parse-literal ; parsing
: dvector{
    \ } [ >double-blas-vector ] parse-literal ; parsing
: cvector{
    \ } [ >float-complex-blas-vector ] parse-literal ; parsing
: zvector{
    \ } [ >double-complex-blas-vector ] parse-literal ; parsing

: smatrix{
    \ } [ >float-blas-matrix ] parse-literal ; parsing
: dmatrix{
    \ } [ >double-blas-matrix ] parse-literal ; parsing
: cmatrix{
    \ } [ >float-complex-blas-matrix ] parse-literal ; parsing
: zmatrix{
    \ } [ >double-complex-blas-matrix ] parse-literal ; parsing

M: float-blas-vector pprint-delims
    drop \ svector{ \ } ;
M: double-blas-vector pprint-delims
    drop \ dvector{ \ } ;
M: float-complex-blas-vector pprint-delims
    drop \ cvector{ \ } ;
M: double-complex-blas-vector pprint-delims
    drop \ zvector{ \ } ;

M: float-blas-matrix pprint-delims
    drop \ smatrix{ \ } ;
M: double-blas-matrix pprint-delims
    drop \ dmatrix{ \ } ;
M: float-complex-blas-matrix pprint-delims
    drop \ cmatrix{ \ } ;
M: double-complex-blas-matrix pprint-delims
    drop \ zmatrix{ \ } ;

M: blas-vector-base >pprint-sequence ;
M: blas-vector-base pprint* pprint-object ;
M: blas-matrix-base >pprint-sequence Mrows ;
M: blas-matrix-base pprint* pprint-object ;
