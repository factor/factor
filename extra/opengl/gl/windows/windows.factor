USING: alien alien.syntax arrays assocs hashtables init kernel
       libc math namespaces parser sequences syntax system vectors
       windows.opengl32 ;

IN: opengl.gl.windows

<PRIVATE

SYMBOL: gl-function-number-counter
SYMBOL: gl-function-pointers

0 gl-function-number-counter set
[ 100 <hashtable> gl-function-pointers set ] "opengl.gl.windows init hook" add-init-hook

: gl-function-number ( -- n )
    gl-function-number-counter get
    dup 1+ gl-function-number-counter set ;

: gl-function-pointer ( name n -- funptr )
    wglGetCurrentContext 2array dup gl-function-pointers get at
    [ -rot 2drop ]
    [ >r wglGetProcAddress dup r> gl-function-pointers get set-at ]
    if* ;

PRIVATE>

: GL-FUNCTION:
    "stdcall"
    scan
    scan
    dup gl-function-number [ gl-function-pointer ] 2curry swap
    scan drop "}" parse-tokens drop
    ";" parse-tokens [ "()" subseq? not ] subset
    define-indirect
    ; parsing
