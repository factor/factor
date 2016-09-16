! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.strings io.encodings.ascii
gdk.gl.ffi ;
IN: opengl.gl.gtk

: gl-function-context ( -- context )
    gdk_gl_context_get_current ; inline

: gl-function-address ( name -- address )
    ascii string>alien gdk_gl_get_proc_address ; inline
