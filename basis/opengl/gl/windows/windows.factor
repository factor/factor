USING: alien.syntax kernel windows.types ;
IN: opengl.gl.windows

LIBRARY: gl

FUNCTION: HGLRC wglGetCurrentContext ( ) ;
FUNCTION: void* wglGetProcAddress ( char* name ) ;

: gl-function-context ( -- context ) wglGetCurrentContext ; inline
: gl-function-address ( name -- address ) wglGetProcAddress ; inline
: gl-function-calling-convention ( -- str ) "stdcall" ; inline
