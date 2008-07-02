USING: kernel math.blas.vectors parser prettyprint.backend ;
IN: math.blas.syntax

: svector{ ( accum -- accum )
    \ } [ >float-blas-vector ] parse-literal ; parsing
: dvector{ ( accum -- accum )
    \ } [ >double-blas-vector ] parse-literal ; parsing
: cvector{ ( accum -- accum )
    \ } [ >float-complex-blas-vector ] parse-literal ; parsing
: zvector{ ( accum -- accum )
    \ } [ >double-complex-blas-vector ] parse-literal ; parsing

