! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.strings cuda cuda.syntax destructors
io.encodings.utf8 kernel locals math prettyprint sequences ;
IN: cuda.hello-world

CUDA-LIBRARY: hello vocab:cuda/hello.ptx

CUDA-FUNCTION: helloWorld ( char* string-ptr ) ;

:: cuda-hello-world ( -- )
    T{ launcher
        { device 0 }
        { path "vocab:cuda/hello.ptx" }
    } [
        "Hello World!" [ - ] map-index malloc-device-string &dispose dup :> str

        T{ function-launcher
            { dim-block { 6 1 1 } }
            { dim-grid { 2 1 } }
            { shared-size 0 }
        }
        helloWorld

        ! <<< { 6 1 1 } { 2 1 } 1 >>> helloWorld

        str device>host utf8 alien>string .
    ] with-cuda ;

MAIN: cuda-hello-world
