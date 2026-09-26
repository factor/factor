! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax kernel opengl.gl.windows
raylib.live-coding.contexts system windows.errors
windows.opengl32 windows.types ;
IN: raylib.live-coding.contexts.windows

LIBRARY: gl
FUNCTION: HDC wglGetCurrentDC ( )

TUPLE: wgl-context dc handle ;
C: <wgl-context> wgl-context

M: windows current-context
    wglGetCurrentContext [ wglGetCurrentDC swap <wgl-context> ] [ f ] if* ;

M: windows make-context-current
    [ [ dc>> ] [ handle>> ] bi ] [ f f ] if*
    wglMakeCurrent win32-error=0/f ;
