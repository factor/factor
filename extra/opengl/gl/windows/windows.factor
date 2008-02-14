USING: kernel windows.opengl32 ;
IN: opengl.gl.windows

: gl-function-context ( -- context ) wglGetCurrentContext ; inline
: gl-function-address ( name -- address ) wglGetProcAddress ; inline
: gl-function-calling-convention ( -- str ) "stdcall" ; inline
