! Copyright (C) 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien arrays cocoa freetype gadgets gadgets-layouts
gadgets-listener hashtables io kernel lists math namespaces objc
objc-NSApplication objc-NSEvent objc-NSMenu
objc-NSNotificationCenter objc-NSObject objc-NSOpenGLContext
objc-NSOpenGLView objc-NSView objc-NSWindow opengl prettyprint
sequences threads walker ;

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

: button ( event -- n )
    #! Cocoa -> Factor UI button mapping
    [buttonNumber] H{ { 0 1 } { 2 2 } { 1 3 } } hash ;

: send-button-down ( event -- )
    update-clicked
    button dup hand get hand-buttons push
    [ button-down ] button-gesture ;

: send-button-up ( event -- )
    button dup hand get hand-buttons delete
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

: modifiers
    {
        { "SHIFT" HEX: 10000 }
        { "CTRL" HEX: 40000 }
        { "ALT" HEX: 80000 }
        { "META" HEX: 100000 }
    } ;

: key-codes
    H{
        { 36 "RETURN" }
        { 48 "TAB" }
        { 51 "BACKSPACE" }
        { 115 "HOME" }
        { 117 "DELETE" }
        { 119 "END" }
        { 123 "LEFT" }
        { 124 "RIGHT" }
        { 125 "DOWN" }
        { 126 "UP" }
    } hash ;

: modifier ( mod -- seq )
    modifiers
    [ second swap bitand 0 > ] subset-with
    [ first ] map ;

: event>binding ( event -- binding )
    dup [modifierFlags] modifier swap [keyCode] key-codes
    [ add >list ] [ drop f ] if* ;

: send-user-input ( event -- )
    [characters] CF>string dup empty?
    [ hand get hand-focus user-input ] unless drop ;

: send-key-event ( event -- )
    dup event>binding
    [ hand get hand-focus handle-gesture ] [ t ] if*
    [ send-user-input ] [ drop ] if ;

: resize-world ( world -- )
    >r [bounds] dup NSRect-w swap NSRect-h 0 3array r>
    set-gadget-dim ;

: init-FactorView-class
    "NSOpenGLView" "FactorView" {
        { "drawRect:" "void" { "id" "SEL" "NSRect" }
            [
                2drop dup [openGLContext] [
                    [bounds] init-gl world get draw-gadget
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
            [ 2nip send-key-event ]
        }

        { "updateFactorGadgetSize:" "void" { "id" "SEL" "id" }
            [ 2drop world get resize-world ]
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
    [initWithFrame:pixelFormat:]
    dup 1 [setPostsBoundsChangedNotifications:]
    dup 1 [setPostsFrameChangedNotifications:] ;

: <FactorWindow> ( gadget title -- window )
    over rect-dim first2 0 0 2swap <NSRect> <NSWindow>
    [ swap <FactorView> [setContentView:] ] 2keep
    [ swap set-world-handle ] keep ;

: NSViewBoundsDidChangeNotification
    "NSViewBoundsDidChangeNotification" <NSString> ;

: NSViewFrameDidChangeNotification
    "NSViewFrameDidChangeNotification" <NSString> ;

: ui
    [
        [
            init-world
        
            world get ui-title <FactorWindow>
    
            dup 1 [setAcceptsMouseMovedEvents:]
    
            dup dup [contentView] [setInitialFirstResponder:]
    
            NSNotificationCenter [defaultCenter]
            over [contentView]
            "updateFactorGadgetSize:" sel_registerName
            NSViewFrameDidChangeNotification
            pick
            [addObserver:selector:name:object:]

            dup f [makeKeyAndOrderFront:]
    
            [contentView] [openGLContext] [makeCurrentContext]
            listener-application
            
            NSApplication [sharedApplication] [finishLaunching]
            event-loop
        ] with-cocoa
    ] with-freetype ;

ui
