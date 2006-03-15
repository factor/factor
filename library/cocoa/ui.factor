! Copyright (C) 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: arrays cocoa freetype gadgets-layouts gadgets-listener
hashtables kernel lists math namespaces objc objc-NSApplication
objc-NSEvent objc-NSObject objc-NSOpenGLView objc-NSView
objc-NSWindow sequences ;

IN: gadgets

: redraw-world ( gadgets -- )
    world-handle [contentView] 1 [setNeedsDisplay:] ;

IN: gadgets-cocoa

! Cocoa backend for Factor UI
: button ( event -- n )
    #! Cocoa -> Factor UI button mapping
    [buttonNumber] H{ { 0 1 } { 2 2 } { 1 3 } } hash ;

: mouse-location ( window -- loc )
    dup [contentView] [
        swap [mouseLocationOutsideOfEventStream] f
        [convertPoint:fromView:]
        dup NSPoint-x swap NSPoint-y
    ] keep [frame] NSRect-h swap - 0 3array ;

: send-mouse-moved ( -- )
    world get world-handle mouse-location move-hand ;

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

: send-key-event ( event -- )
    dup event>binding
    [ hand get hand-focus handle-gesture ] [ t ] if*
    [ [characters] CF>string send-user-input ] [ drop ] if ;

"NSOpenGLView" "FactorView" {
    { "drawRect:" "void" { "id" "SEL" "NSRect" }
        [
            2drop dup [openGLContext] [
                view-dim init-gl world get draw-gadget
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
        [ 2nip button send-button-down ]
    }
    
    { "mouseUp:" "void" { "id" "SEL" "id" }
        [ 2nip button send-button-up ]
    }
    
    { "rightMouseDown:" "void" { "id" "SEL" "id" }
        [ 2nip button send-button-down ]
    }
    
    { "rightMouseUp:" "void" { "id" "SEL" "id" }
        [ 2nip button send-button-up ]
    }
    
    { "otherMouseDown:" "void" { "id" "SEL" "id" }
        [ 2nip button send-button-down ]
    }
    
    { "otherMouseUp:" "void" { "id" "SEL" "id" }
        [ 2nip button send-button-up ]
    }
    
    { "scrollWheel:" "void" { "id" "SEL" "id" }
        [ 2nip [deltaY] 0 > send-scroll-wheel ]
    }
    
    { "keyDown:" "void" { "id" "SEL" "id" }
        [ 2nip send-key-event ]
    }

    { "updateFactorGadgetSize:" "void" { "id" "SEL" "id" }
        [ 2drop view-dim world get set-gadget-dim ]
    }
    
    { "acceptsFirstResponder" "bool" { "id" "SEL" }
        [ 2drop 1 ]
    }
} { } define-objc-class

IN: objc-FactorView
DEFER: FactorView

IN: gadgets-cocoa

: <FactorView> ( gadget -- view )
    drop
    FactorView [alloc]
    0 0 100 100 <NSRect> NSOpenGLView [defaultPixelFormat]
    [initWithFrame:pixelFormat:]
    dup 1 [setPostsBoundsChangedNotifications:]
    dup 1 [setPostsFrameChangedNotifications:]
    dup "updateFactorGadgetSize:" add-resize-observer ;

: <FactorWindow> ( gadget title -- window )
    over rect-dim first2 0 0 2swap <NSRect> <NSWindow>
    [ swap <FactorView> [setContentView:] ] 2keep
    [ swap set-world-handle ] keep
    dup 1 [setAcceptsMouseMovedEvents:]
    dup dup [contentView] [setInitialFirstResponder:]
    dup f [makeKeyAndOrderFront:] ;

IN: shells

: ui
    [
        [
            init-world
        
            world get ui-title <FactorWindow>
    
            listener-application
            
            NSApplication [sharedApplication] [finishLaunching]
            
            event-loop
        ] with-cocoa
    ] with-freetype ;
