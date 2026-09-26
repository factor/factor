! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: cocoa cocoa.classes kernel raylib.live-coding.contexts
system ;
IN: raylib.live-coding.contexts.cocoa

! Raylib's bundled GLFW and Factor's UI both use NSOpenGLContext.
! Capture the native context, not GetWindowHandle's NSWindow pointer.
M: macos current-context NSOpenGLContext -> currentContext ;

M: macos make-context-current
    [ -> makeCurrentContext ]
    [ NSOpenGLContext -> clearCurrentContext ] if* ;
