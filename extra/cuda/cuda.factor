! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data alien.parser alien.strings
alien.syntax arrays assocs byte-arrays classes.struct
combinators continuations cuda.ffi
destructors fry init io io.backend io.encodings.string
io.encodings.utf8 kernel lexer locals macros math math.parser
namespaces opengl.gl.extensions parser prettyprint quotations
sequences words ;
QUALIFIED-WITH: alien.c-types c
IN: cuda

TUPLE: cuda-error code ;

: cuda-error ( code -- )
    dup CUDA_SUCCESS = [ drop ] [ \ cuda-error boa throw ] if ;

: cuda-version ( -- n )
    c:int <c-object> [ cuDriverGetVersion cuda-error ] keep c:*int ;

: init-cuda ( -- )
    0 cuInit cuda-error ; inline

