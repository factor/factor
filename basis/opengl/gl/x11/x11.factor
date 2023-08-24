USING: x11.glx ;
IN: opengl.gl.x11

: gl-function-context ( -- context ) glXGetCurrentContext ; inline
: gl-function-address ( name -- address ) glXGetProcAddressARB ; inline
