IN: gl
USING: alien parser sequences kernel ;

win32? [
    "gl" "opengl32.dll" "stdcall" add-library
    "glu" "glu32.dll" "stdcall" add-library
] [
    "gl" "libGL.so" "cdecl" add-library
    "glu" "libGLU.so" "cdecl" add-library
] ifte

[ "gl-internals.factor" "sdl-gl.factor" "gl.factor" "glu.factor" ]
[ "contrib/gl/" swap append run-file ] each
