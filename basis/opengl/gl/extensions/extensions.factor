USING: alien alien.syntax alien.parser combinators
kernel parser sequences system words namespaces hashtables init
math arrays assocs continuations lexer fry locals vocabs.parser ;
IN: opengl.gl.extensions

ERROR: unknown-gl-platform ;
<< {
    { [ os windows? ] [ "opengl.gl.windows" ] }
    { [ os macos? ]  [ "opengl.gl.macos" ] }
    { [ os unix? ] [ "opengl.gl.gtk" ] }
    [ unknown-gl-platform ]
} cond use-vocab >>

SYMBOL: +gl-function-counter+
SYMBOL: +gl-function-pointers+

: reset-gl-function-number-counter ( -- )
    0 +gl-function-counter+ set-global ;
: reset-gl-function-pointers ( -- )
    100 <hashtable> +gl-function-pointers+ set-global ;

STARTUP-HOOK: reset-gl-function-pointers

reset-gl-function-pointers
reset-gl-function-number-counter

: gl-function-counter ( -- n )
    +gl-function-counter+ counter ;

: gl-function-pointer ( names n -- funptr )
    gl-function-context 2array dup +gl-function-pointers+ get-global at
    [ 2nip ] [
        [
            [ gl-function-address ] map [ ] find nip
            dup [ "OpenGL function not available" throw ] unless
            dup
        ] dip
        +gl-function-pointers+ get-global set-at
    ] if* ;

: indirect-quot ( function-ptr-quot return types abi -- quot )
    '[ @  _ _ _ alien-indirect ] ;

:: define-indirect ( abi return function-name function-ptr-quot types names -- )
    function-name create-function
    function-ptr-quot return types abi indirect-quot
    names return function-effect
    define-declared ;

: gl-function-calling-convention ( -- symbol )
    os windows? [ stdcall ] [ cdecl ] if ;

SYNTAX: GL-FUNCTION:
    gl-function-calling-convention
    scan-function-name
    "{" expect "}" parse-tokens over prefix
    gl-function-counter '[ _ _ gl-function-pointer ]
    scan-c-args define-indirect ;

