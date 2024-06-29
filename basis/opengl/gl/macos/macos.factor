USING: kernel alien alien.libraries ;
IN: opengl.gl.macos

: gl-function-context ( -- context ) 0 ; inline
: gl-function-address ( name -- address ) f dlsym ; inline
