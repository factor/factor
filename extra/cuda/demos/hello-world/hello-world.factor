! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings cuda cuda.devices
cuda.memory cuda.syntax cuda.utils destructors io
io.encodings.string io.encodings.utf8 kernel locals math
math.parser namespaces sequences ;
IN: cuda.demos.hello-world

CUDA-LIBRARY: hello vocab:cuda/demos/hello-world/hello.ptx

CUDA-FUNCTION: helloWorld ( char* string-ptr ) ;

: cuda-hello-world ( -- )
    [
        cuda-launcher get device>> number>string
        "CUDA device " ": " surround write
        "Hello World!" [ - ] map-index host>device

        [ { 6 1 1 } { 2 1 } 2<<< helloWorld ]
        [ device>host utf8 decode print ] bi
    ] with-each-cuda-device ;

MAIN: cuda-hello-world
