USING: alien alien.syntax kernel libc namespaces parser
       sequences syntax system vectors ;

IN: opengl.gl.windows

SYMBOL: gl-function-pointers

LIBRARY: gl
FUNCTION: void* wglGetProcAddress ( char* name ) ;

: GL-FUNCTION:
    "stdcall"
    scan
    scan
    dup [ wglGetProcAddress check-ptr ] curry swap
    ";" parse-tokens [ "()" subseq? not ] subset
    define-indirect
    ; parsing
