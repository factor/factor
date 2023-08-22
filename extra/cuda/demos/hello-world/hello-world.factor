! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types cuda cuda.contexts cuda.devices
cuda.libraries cuda.memory cuda.syntax destructors io
io.encodings.string io.encodings.utf8 kernel math math.parser
sequences strings ;
IN: cuda.demos.hello-world

CUDA-LIBRARY: hello cuda32 "vocab:cuda/demos/hello-world/hello.ptx"

CUDA-FUNCTION: helloWorld ( char* string-ptr )

: cuda-hello-world ( -- )
    init-cuda
    [
        [
            context-device number>string
            "CUDA device " ": " surround write
            "Hello World!" utf8 encode [ - ] B{ } map-index-as host>device &cuda-free
            [ { 2 1 } { 6 1 1 } <grid> helloWorld ]
            [ 12 device>host >string print ] bi
        ] with-destructors
    ] with-each-cuda-device ;

MAIN: cuda-hello-world
