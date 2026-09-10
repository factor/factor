! Copyright (C) 2025 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.accessors alien.libraries alien.syntax kernel
sequences system ui.backend ;
IN: opengl.gl.epoxy

: gl-function-context ( -- context )
    current-gl-context ; inline

LIBRARY: epoxy

C-LIBRARY: epoxy {
    { linux "libepoxy.so.0" }
    { unix "libepoxy.so" }
}

: gl-function-address ( name -- address )
    ! libepoxy exports function pointer variables (epoxy_glXXX),
    ! not the actual functions. dlsym returns the address of the
    ! variable, so we must dereference it to get the function pointer.
    "epoxy_" prepend "epoxy" library-dll dlsym
    dup [ 0 alien-cell ] when ; inline
