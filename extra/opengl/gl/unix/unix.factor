USING: kernel x11.glx ;
IN: opengl.gl.unix

: gl-function-context ( -- context ) glXGetCurrentContext ; inline
: gl-function-address ( name -- address ) glXGetProcAddress ; inline
: gl-function-calling-convention ( -- str ) "cdecl" ; inline
