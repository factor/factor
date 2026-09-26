! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries alien.syntax
combinators kernel locals math sequences system raylib.live-coding.contexts ;
IN: raylib.live-coding.contexts.unix

! Load the native APIs, not another copy of Raylib's windowing library.
! Either library can be absent (for example, GLX on a Wayland-only system).
<<
"raylib-live-glx" "libGL.so.1" cdecl add-library
"raylib-live-egl" "libEGL.so.1" cdecl add-library
>>

LIBRARY: raylib-live-glx
FUNCTION: void* glXGetCurrentContext ( )
FUNCTION: void* glXGetCurrentDisplay ( )
FUNCTION: ulong glXGetCurrentDrawable ( )
FUNCTION: ulong glXGetCurrentReadDrawable ( )
FUNCTION: int glXMakeContextCurrent ( void* display, ulong draw, ulong read, void* context )

LIBRARY: raylib-live-egl
FUNCTION: void* eglGetCurrentContext ( )
FUNCTION: void* eglGetCurrentDisplay ( )
FUNCTION: void* eglGetCurrentSurface ( int which )
FUNCTION: uint eglQueryAPI ( )
FUNCTION: uint eglBindAPI ( uint api )
FUNCTION: uint eglMakeCurrent ( void* display, void* draw, void* read, void* context )
FUNCTION: int eglGetError ( )

CONSTANT: EGL_DRAW 0x3059
CONSTANT: EGL_READ 0x305a

TUPLE: glx-context display draw read handle ;
C: <glx-context> glx-context
TUPLE: egl-context display draw read handle api ;
C: <egl-context> egl-context

ERROR: context-switch-failed api error ;

<PRIVATE

: library-loaded? ( name -- ? )
    library-dll [ dll-valid? ] [ f ] if* ;

: glx-current-context ( -- context/f )
    "raylib-live-glx" library-loaded? [
        glXGetCurrentContext [
            [ glXGetCurrentDisplay glXGetCurrentDrawable
              glXGetCurrentReadDrawable ] dip <glx-context>
        ] [ f ] if*
    ] [ f ] if ;

: egl-current-context ( -- context/f )
    "raylib-live-egl" library-loaded? [
        eglGetCurrentContext [
            [ eglGetCurrentDisplay EGL_DRAW eglGetCurrentSurface
              EGL_READ eglGetCurrentSurface ] dip
            eglQueryAPI <egl-context>
        ] [ f ] if*
    ] [ f ] if ;

: check-egl ( result -- )
    zero? [ "EGL" eglGetError context-switch-failed ] when ;

: check-glx ( result -- )
    zero? [ "GLX" f context-switch-failed ] when ;

: clear-gdk-context ( -- )
    ! GDK caches the current context. Invalidate that cache as well as
    ! the native binding so its next make-current actually rebinds.
    ! Only consult libraries already loaded by the UI: GTK3 and GTK4
    ! must never be loaded together merely to switch GL contexts.
    { "gdk3" "gdk4" } [
        dup library-loaded? [
            "gdk_gl_context_clear_current" swap dlsym?
            [ void { } cdecl alien-indirect ] when*
        ] [ drop ] if
    ] each ;

: clear-native-context ( -- )
    clear-gdk-context
    egl-current-context [ display>> f f f eglMakeCurrent check-egl ] when*
    glx-current-context [ display>> 0 0 f glXMakeContextCurrent check-glx ] when* ;

GENERIC: restore-context ( context -- )
M: f restore-context drop ;
M: glx-context restore-context
    { [ display>> ] [ draw>> ] [ read>> ] [ handle>> ] } cleave
    glXMakeContextCurrent check-glx ;
M: egl-context restore-context
    dup api>> eglBindAPI check-egl
    { [ display>> ] [ draw>> ] [ read>> ] [ handle>> ] } cleave
    eglMakeCurrent check-egl ;

PRIVATE>

M: unix current-context
    egl-current-context [ glx-current-context ] unless* ;

M: unix make-context-current
    clear-native-context restore-context ;
