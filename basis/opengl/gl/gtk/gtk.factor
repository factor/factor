! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.strings gdk2.gl.ffi io.encodings.ascii ;
IN: opengl.gl.gtk

: gl-function-context ( -- context )
    gdk_gl_context_get_current ; inline

: gl-function-address ( name -- address )
    ascii string>alien gdk_gl_get_proc_address ; inline
