! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: objc-FactorView
DEFER: FactorView
IN: objc-FactorUIWindowDelegate
DEFER: FactorUIWindowDelegate

USING: alien arrays cocoa errors freetype gadgets
gadgets-launchpad gadgets-layouts gadgets-listener gadgets-panes
hashtables kernel math namespaces objc objc-NSApplication
objc-NSEvent objc-NSObject objc-NSOpenGLContext
objc-NSOpenGLView objc-NSView objc-NSWindow sequences threads ;

! Cocoa backend for Factor UI

IN: gadgets-cocoa

! Hash mapping aliens to gadgets
SYMBOL: views

: reset-views ( hash -- hash ) H{ } clone views set-global ;

reset-views

: view ( handle -- world ) views get hash ;

: mouse-location ( view event -- loc )
    over >r
    [locationInWindow] f [convertPoint:fromView:]
    dup NSPoint-x swap NSPoint-y
    r> [frame] NSRect-h swap - 0 3array ;

: send-mouse-moved ( view event -- )
    over >r mouse-location r> view move-hand ;

: button ( event -- n )
    #! Cocoa -> Factor UI button mapping
    [buttonNumber] H{ { 0 1 } { 2 2 } { 1 3 } } hash ;

: button&loc ( view event -- button# loc )
    dup button -rot mouse-location ;

: modifiers
    {
        { S+ HEX: 10000 }
        { C+ HEX: 40000 }
        { A+ HEX: 80000 }
        { M+ HEX: 100000 }
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
    } ;

: key-code ( event -- string )
    dup [keyCode] key-codes hash
    [ ] [ [charactersIgnoringModifiers] CF>string ] ?if ;

: event>gesture ( event -- modifiers keycode )
    dup [modifierFlags] modifiers modifier swap key-code ;

: send-key-event ( view event quot -- )
    >r event>gesture r> call swap view world-focus
    handle-gesture ; inline

: send-user-input ( view event -- )
    [characters] CF>string swap view world-focus user-input ;

: send-key-down-event ( view event -- )
    2dup [ <key-down> ] send-key-event
    [ send-user-input ] [ 2drop ] if ;

: send-key-up-event ( view event -- )
    [ <key-up> ] send-key-event ;

: send-button-down$ ( view event -- )
    over >r button&loc r> view send-button-down ;

: send-button-up$ ( view event -- )
    over >r button&loc r> view send-button-up ;

: send-wheel$ ( view event -- )
    [ [deltaY] 0 > ] 2keep mouse-location rot view send-wheel ;

"NSOpenGLView" "FactorView" {
    { "drawRect:" "void" { "id" "SEL" "NSRect" }
        [ 2drop view draw-world ]
    }
    
    { "mouseMoved:" "void" { "id" "SEL" "id" }
        [ nip send-mouse-moved ]
    }
    
    { "mouseDragged:" "void" { "id" "SEL" "id" }
        [ nip send-mouse-moved ]
    }
    
    { "rightMouseDragged:" "void" { "id" "SEL" "id" }
        [ nip send-mouse-moved ]
    }
    
    { "otherMouseDragged:" "void" { "id" "SEL" "id" }
        [ nip send-mouse-moved ]
    }
    
    { "mouseDown:" "void" { "id" "SEL" "id" }
        [ nip send-button-down$ ]
    }
    
    { "mouseUp:" "void" { "id" "SEL" "id" }
        [ nip send-button-up$ ]
    }
    
    { "rightMouseDown:" "void" { "id" "SEL" "id" }
        [ nip send-button-down$ ]
    }
    
    { "rightMouseUp:" "void" { "id" "SEL" "id" }
        [ nip send-button-up$ ]
    }
    
    { "otherMouseDown:" "void" { "id" "SEL" "id" }
        [ nip send-button-down$ ]
    }
    
    { "otherMouseUp:" "void" { "id" "SEL" "id" }
        [ nip send-button-up$ ]
    }
    
    { "scrollWheel:" "void" { "id" "SEL" "id" }
        [ nip send-wheel$ ]
    }
    
    { "keyDown:" "void" { "id" "SEL" "id" }
        [ nip send-key-down-event ]
    }
    
    { "keyUp:" "void" { "id" "SEL" "id" }
        [ nip send-key-up-event ]
    }

    { "updateFactorGadgetSize:" "void" { "id" "SEL" "id" }
        [ 2drop dup view-dim swap view set-gadget-dim ]
    }
    
    { "acceptsFirstResponder" "bool" { "id" "SEL" }
        [ 2drop 1 ]
    }
    
    { "initWithFrame:pixelFormat:" "id" { "id" "SEL" "NSRect" "id" }
        [
            rot drop
            SUPER-> [initWithFrame:pixelFormat:]
            dup "updateFactorGadgetSize:" add-resize-observer
        ]
    }
    
    { "dealloc" "void" { "id" "SEL" }
        [
            drop
            dup view close-world
            dup views get remove-hash
            dup remove-observer
            SUPER-> [dealloc]
        ]
    }
} { } define-objc-class

: register-view ( world -- )
    dup world-handle views get set-hash ;

: <FactorView> ( gadget -- view )
    FactorView over rect-dim <GLView>
    [ over set-world-handle dup add-notify register-view ] keep ;


: window-root-gadget-pref-dim  [contentView] view pref-dim ;

: frame-rect-for-window-content-rect ( window rect -- rect )
    swap [styleMask] NSWindow -rot [frameRectForContentRect:styleMask:] ;

: content-rect-for-window-frame-rect ( window rect -- rect )
    swap [styleMask] NSWindow -rot [contentRectForFrameRect:styleMask:] ;

: window-content-rect ( window -- rect )
    dup [frame] content-rect-for-window-frame-rect ;

"NSObject" "FactorUIWindowDelegate" {
    { "windowWillUseStandardFrame:defaultFrame:" "NSRect" { "id" "SEL" "id" "NSRect" }
        [
            drop 2nip
            dup window-content-rect NSRect-x-far-y
            pick window-root-gadget-pref-dim first2
            <far-y-NSRect>
            frame-rect-for-window-content-rect
        ]
    }
} { } define-objc-class

: install-window-delegate ( window -- )
    FactorUIWindowDelegate [alloc] [init] [setDelegate:] ;

IN: gadgets

: redraw-world ( handle -- )
    world-handle 1 [setNeedsDisplay:] ;

: open-window* ( world title -- )
    >r <FactorView> r> <ViewWindow> 
    dup install-window-delegate
    [contentView] [release] ;

: select-gl-context ( handle -- )
    [openGLContext] [makeCurrentContext] ;

: flush-gl-context ( handle -- )
    [openGLContext] [flushBuffer] ;

IN: shells

: ui
    running.app? [
        "The Factor UI requires you to run the supplied Factor.app." throw
    ] unless
    [
        [
            reset-views
            reset-callbacks
            init-ui
            default-main-menu
            listener-window
            finish-launching
            event-loop
        ] with-cocoa
    ] with-freetype ;

IN: kernel

: default-shell running.app? "ui" "tty" ? ;
