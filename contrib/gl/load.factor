IN: gl
USING: alien parser sequences kernel ;

"gl" "libGL.so" "stdcall" add-library
"glu" "libGLU.so" "stdcall" add-library
[ "gl-internals.factor" "sdl-gl.factor" "gl.factor" "glu.factor" ] [ "contrib/gl/" swap append run-file ] each
