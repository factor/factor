! Copyright (C) 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien arrays cocoa freetype gadgets gadgets-layouts
gadgets-listener io kernel math namespaces objc
objc-NSApplication objc-NSEvent objc-NSMenu objc-NSObject
objc-NSOpenGLContext objc-NSOpenGLView objc-NSView objc-NSWindow
opengl prettyprint sequences threads walker ;

IN: gadgets

: redraw-world ( gadgets -- )
    world-handle [contentView] 1 [setNeedsDisplay:] ;

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

: send-button-down ( event -- )
    update-clicked
    [buttonNumber] dup hand get hand-buttons push
    [ button-down ] button-gesture ;

: send-button-up ( event -- )
    [buttonNumber] dup hand get hand-buttons delete
    [ button-up ] button-gesture ;

: mouse-location ( window -- loc )
    dup [contentView] [
        swap [mouseLocationOutsideOfEventStream] f
        [convertPoint:fromView:]
        dup NSPoint-x swap NSPoint-y
    ] keep [frame] NSRect-h swap - 0 3array ;

: send-mouse-moved ( -- )
    world get world-handle mouse-location move-hand ;

: send-scroll-wheel ( event -- )
    [deltaY] 0 >
    [ wheel-up ] [ wheel-down ] ?
    hand get hand-clicked handle-gesture drop ;

! M: key-down-event handle-event ( event -- )
!     dup keyboard-event>binding
!     hand get hand-focus handle-gesture [
!         keyboard-event-unicode dup control? [
!             drop
!         ] [
!             hand get hand-focus user-input drop
!         ] if
!     ] [
!         drop
!     ] if ;

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
        
        { "mouseMoved:" "void" { "id" "SEL" "id" }
            [ 3drop send-mouse-moved ]
        }
        
        { "mouseDragged:" "void" { "id" "SEL" "id" }
            [ 3drop send-mouse-moved ]
        }
        
        { "rightMouseDragged:" "void" { "id" "SEL" "id" }
            [ 3drop send-mouse-moved ]
        }
        
        { "otherMouseDragged:" "void" { "id" "SEL" "id" }
            [ 3drop send-mouse-moved ]
        }
        
        { "mouseDown:" "void" { "id" "SEL" "id" }
            [ 2nip send-button-down ]
        }
        
        { "mouseUp:" "void" { "id" "SEL" "id" }
            [ 2nip send-button-up ]
        }
        
        { "rightMouseDown:" "void" { "id" "SEL" "id" }
            [ 2nip send-button-down ]
        }
        
        { "rightMouseUp:" "void" { "id" "SEL" "id" }
            [ 2nip send-button-up ]
        }
        
        { "otherMouseDown:" "void" { "id" "SEL" "id" }
            [ 2nip send-button-down ]
        }
        
        { "otherMouseUp:" "void" { "id" "SEL" "id" }
            [ 2nip send-button-up ]
        }
        
        { "scrollWheel:" "void" { "id" "SEL" "id" }
            [ 2nip send-scroll-wheel ]
        }
        
        { "keyDown:" "void" { "id" "SEL" "id" }
            [
                2nip [characters] CF>string dup . flush
                hand get hand-focus user-input drop
            ]
        }

        { "reshape" "void" { "id" "SEL" }
            [ drop 1 [setNeedsDisplay:] ]
        }
        
        { "acceptsFirstResponder" "bool" { "id" "SEL" }
            [ 2drop 1 ]
        }
    } { } define-objc-class ; parsing

init-FactorView-class

USE: objc-FactorView

: <FactorView> ( gadget -- view )
    drop
    FactorView [alloc]
    0 0 100 100 <NSRect> NSOpenGLView [defaultPixelFormat]
    [initWithFrame:pixelFormat:] ;

: <FactorWindow> ( gadget title -- window )
    over rect-dim first2 0 0 2swap <NSRect> <NSWindow>
    [ swap <FactorView> [setContentView:] ] 2keep
    [ swap set-world-handle ] keep ;

: ui
    [
        [
            ! NSApplication NSMenu [alloc] [init] [setMainMenu:]
            init-world
        
            world get ui-title <FactorWindow>
    
            dup 1 [setAcceptsMouseMovedEvents:]
    
            dup dup [contentView] [setInitialFirstResponder:]
    
            dup f [makeKeyAndOrderFront:]
    
            [contentView] [openGLContext] [makeCurrentContext]
            listener-application
            
            NSApplication [sharedApplication] [finishLaunching]
            event-loop
        ] with-cocoa
    ] with-freetype ;

ui
