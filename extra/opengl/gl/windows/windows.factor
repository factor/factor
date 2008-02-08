USING: kernel windows.opengl32 ;
IN: opengl.gl.windows

: gl-function-context ( -- context ) wglGetCurrentContext alien-address ; inline
: gl-function-address ( name -- address ) wglGetProcAddress ; inline
: gl-function-calling-convention ( -- str ) "stdcall" ; inline
