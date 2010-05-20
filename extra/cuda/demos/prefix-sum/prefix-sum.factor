! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types cuda cuda.contexts cuda.syntax locals ;
IN: cuda.demos.prefix-sum

CUDA-LIBRARY: prefix-sum vocab:cuda/demos/prefix-sum/prefix-sum.ptx

CUDA-FUNCTION: prefix_sum_block ( uint* in, uint* out, uint n ) ;

:: cuda-prefix-sum ( -- )
    init-cuda
    0 0 [
        ! { 1 1 1 } { 2 1 } 0 <grid-shared> prefix_sum_block
    ] with-cuda-context ;

MAIN: cuda-prefix-sum
