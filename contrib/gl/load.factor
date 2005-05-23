IN: gl
USING: alien parser sequences kernel ;

"gl" "libGL.so" "cdecl" add-library
"glu" "libGLU.so" "cdecl" add-library
[ "gl-internals.factor" "sdl-gl.factor" "gl.factor" "glu.factor" ] [ "contrib/gl/" swap append run-file ] each
