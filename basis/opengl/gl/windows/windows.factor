USING: alien alien.c-types alien.libraries alien.syntax kernel
windows.types ;
IN: opengl.gl.windows

LIBRARY: gl

FUNCTION: HGLRC wglGetCurrentContext ( )
FUNCTION: void* wglGetProcAddress ( c-string name )

: gl-function-context ( -- context ) wglGetCurrentContext ; inline
: gl-function-address ( name -- address )
    dup DLL" opengl32.dll" dlsym [ nip ] [ wglGetProcAddress ] if* ; inline
