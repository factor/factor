! Copyright (C) 2025 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
! Compatibility vocabulary for the shared GTK OpenGL resolver.
USING: opengl.gl.epoxy ;
IN: opengl.gl.gtk3

: gl-function-context ( -- context )
    opengl.gl.epoxy:gl-function-context ; inline

: gl-function-address ( name -- address )
    opengl.gl.epoxy:gl-function-address ; inline
