! Copyright (C) 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien arrays cocoa freetype gadgets gadgets-layouts
gadgets-listener io kernel namespaces objc objc-NSApplication
objc-NSObject objc-NSOpenGLContext objc-NSOpenGLView objc-NSView
objc-NSWindow opengl prettyprint sequences threads walker ;
IN: gadgets-cocoa

! Cocoa backend for Factor UI
: init-gl ( rect -- )
    0.0 0.0 0.0 0.0 glClearColor 
    { 1.0 0.0 0.0 0.0 } gl-color
    GL_COLOR_BUFFER_BIT glClear
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    { 0 0 0 } over NSRect-w pick NSRect-h 0 3array <rect>
    clip set
    dup NSRect-w over NSRect-h 0 0 2swap glViewport
    dup NSRect-w swap NSRect-h >r >r 0 r> r> 0 gluOrtho2D
    GL_SMOOTH glShadeModel
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    GL_SCISSOR_TEST glEnable
    GL_MODELVIEW glMatrixMode ;

: with-gl-context ( context quot -- )
    swap
    [ [makeCurrentContext] call glFlush ] keep
    [flushBuffer] ; inline

: init-FactorView-class
    "NSOpenGLView" "FactorView" {
        { "drawRect:" "void" { "id" "SEL" "NSRect" }
            [
                2drop dup [openGLContext] [
                    [bounds] init-gl
                    world get draw-gadget
                ] with-gl-context
            ]
        }
        
        { "reshape" "void" { "id" "SEL" }
            [
                drop 1 [setNeedsDisplay:]
            ]
        }
    } { } define-objc-class ; parsing

init-FactorView-class

USE: objc-FactorView

: <FactorView> ( gadget -- view )
    FactorView [alloc]
    0 0 100 100 <NSRect> NSOpenGLView [defaultPixelFormat]
    [initWithFrame:pixelFormat:]
    [ swap set-world-handle ] keep ;

: <FactorWindow> ( gadget title -- window )
    over rect-dim first2 0 0 2swap <NSRect> <NSWindow>
    [ swap <FactorView> [setContentView:] ] keep
    dup f [makeKeyAndOrderFront:] ;

[
    [
        init-world
    
        world get ui-title <FactorWindow>

        [contentView] [openGLContext] [makeCurrentContext]
        listener-application
        
        event-loop
    ] with-cocoa
] with-freetype
