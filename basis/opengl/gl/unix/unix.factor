USING: alien kernel x11.glx ;
IN: opengl.gl.unix

: gl-function-context ( -- context ) glXGetCurrentContext ; inline
: gl-function-address ( name -- address ) glXGetProcAddressARB ; inline
: gl-function-calling-convention ( -- str ) cdecl ; inline
