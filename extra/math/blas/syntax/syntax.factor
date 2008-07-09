USING: kernel math.blas.matrices math.blas.vectors parser ;
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
