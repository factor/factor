USING: kernel math.blas.matrices math.blas.vectors parser
arrays prettyprint.backend sequences ;
IN: math.blas.syntax

: svector{ ( accum -- accum )
    \ } [ >float-blas-vector ] parse-literal ; parsing
: dvector{ ( accum -- accum )
    \ } [ >double-blas-vector ] parse-literal ; parsing
: cvector{ ( accum -- accum )
    \ } [ >float-complex-blas-vector ] parse-literal ; parsing
: zvector{ ( accum -- accum )
    \ } [ >double-complex-blas-vector ] parse-literal ; parsing

: smatrix{ ( accum -- accum )
    \ } [ >float-blas-matrix ] parse-literal ; parsing
: dmatrix{ ( accum -- accum )
    \ } [ >double-blas-matrix ] parse-literal ; parsing
: cmatrix{ ( accum -- accum )
    \ } [ >float-complex-blas-matrix ] parse-literal ; parsing
: zmatrix{ ( accum -- accum )
    \ } [ >double-complex-blas-matrix ] parse-literal ; parsing

M: float-blas-vector pprint-delims drop \ svector{ \ } ;
M: double-blas-vector pprint-delims drop \ dvector{ \ } ;
M: float-complex-blas-vector pprint-delims drop \ cvector{ \ } ;
M: double-complex-blas-vector pprint-delims drop \ zvector{ \ } ;

M: float-blas-matrix pprint-delims drop \ smatrix{ \ } ;
M: double-blas-matrix pprint-delims drop \ dmatrix{ \ } ;
M: float-complex-blas-matrix pprint-delims drop \ cmatrix{ \ } ;
M: double-complex-blas-matrix pprint-delims drop \ zmatrix{ \ } ;

M: blas-vector-base >pprint-sequence ;
M: blas-matrix-base >pprint-sequence Mrows [ >array ] map ;
