! Copyright (C) 2025 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.accessors alien.libraries alien.syntax gdk3.ffi
kernel sequences system ;
IN: opengl.gl.gtk3

: gl-function-context ( -- context )
    gdk_gl_context_get_current ; inline

LIBRARY: epoxy

C-LIBRARY: epoxy {
    { unix "libepoxy.so" }
}

: gl-function-address ( name -- address )
    ! libepoxy exports function pointer variables (epoxy_glXXX),
    ! not the actual functions. dlsym returns the address of the
    ! variable, so we must dereference it to get the function pointer.
    "epoxy_" prepend DLL" libepoxy.so" dlsym
    dup [ 0 alien-cell ] when ; inline
