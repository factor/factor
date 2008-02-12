USING: kernel alien ;
IN: opengl.gl.macosx

: gl-function-context ( -- context ) 0 ; inline
: gl-function-address ( name -- address ) "gl" load-library dlsym ; inline
: gl-function-calling-convention ( -- str ) "cdecl" ; inline
