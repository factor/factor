! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data cuda.ffi kernel ;
QUALIFIED-WITH: alien.c-types c
IN: cuda

ERROR: cuda-error-state code ;

: cuda-error ( code -- )
    dup CUDA_SUCCESS = [ drop ] [ cuda-error-state ] if ;

: cuda-version ( -- n )
    { c:int } [ cuDriverGetVersion cuda-error ] with-out-parameters ;

: init-cuda ( -- )
    0 cuInit cuda-error ; inline
