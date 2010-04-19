! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.strings cuda cuda.memory cuda.syntax
destructors io io.encodings.utf8 kernel locals math sequences ;
IN: cuda.demos.hello-world

CUDA-LIBRARY: hello vocab:cuda/demos/hello-world/hello.ptx

CUDA-FUNCTION: helloWorld ( char* string-ptr ) ;

:: cuda-hello-world ( -- )
    T{ launcher { device 0 } } [
        "Hello World!" [ - ] map-index malloc-device-string
        &dispose dup :> str

        { 6 1 1 } { 2 1 } 1 3<<< helloWorld

        str device>host utf8 alien>string print
    ] with-cuda ;

MAIN: cuda-hello-world
