! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel namespaces opengl.capabilities opengl.gl variants ;
IN: gpu

TUPLE: gpu-object < identity-tuple handle ;

<PRIVATE

VARIANT: gpu-api
    opengl-2 opengl-3 ;

SYMBOL: has-vertex-array-objects?

: set-gpu-api ( -- )
    "2.0" require-gl-version
    "3.0" { { "GL_ARB_vertex_array_object" "GL_APPLE_vertex_array_object" } }
    has-gl-version-or-extensions? has-vertex-array-objects? set-global
    "3.0" has-gl-version? opengl-3 opengl-2 ? gpu-api set-global ;

HOOK: init-gpu-api gpu-api ( -- )

M: opengl-2 init-gpu-api
    GL_POINT_SPRITE glEnable ;
M: opengl-3 init-gpu-api
    ;

PRIVATE>

: init-gpu ( -- )
    set-gpu-api
    init-gpu-api ;

: reset-gpu ( -- )
    "3.0" { { "GL_APPLE_vertex_array_object" "GL_ARB_vertex_array_object" } }
    has-gl-version-or-extensions?
    [ 0 glBindVertexArray ] when

    "3.0" { { "GL_EXT_framebuffer_object" "GL_ARB_framebuffer_object" } }
    has-gl-version-or-extensions?  [
        GL_DRAW_FRAMEBUFFER 0 glBindFramebuffer
        GL_READ_FRAMEBUFFER 0 glBindFramebuffer
        GL_RENDERBUFFER 0 glBindRenderbuffer
    ] when

    "1.5" { "GL_ARB_vertex_buffer_object" }
    has-gl-version-or-extensions? [
        GL_ARRAY_BUFFER 0 glBindBuffer
        GL_ELEMENT_ARRAY_BUFFER 0 glBindBuffer
    ] when

    "2.1" { "GL_ARB_pixel_buffer_object" }
    has-gl-version-or-extensions? [
        GL_PIXEL_PACK_BUFFER 0 glBindBuffer
        GL_PIXEL_UNPACK_BUFFER 0 glBindBuffer
    ] when

    "2.0" { "GL_ARB_shader_objects" }
    has-gl-version-or-extensions?
    [ 0 glUseProgram ] when ;

: flush-gpu ( -- )
    glFlush ;

: finish-gpu ( -- )
    glFinish ;
