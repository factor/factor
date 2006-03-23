! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: objc-FactorView
DEFER: FactorView

USING: arrays cocoa errors freetype gadgets gadgets-launchpad
gadgets-layouts gadgets-listener gadgets-panes hashtables kernel
lists math namespaces objc objc-NSApplication objc-NSEvent
objc-NSObject objc-NSOpenGLContext objc-NSOpenGLView objc-NSView
objc-NSWindow sequences threads ;

! Cocoa backend for Factor UI

IN: gadgets-cocoa

! Hash mapping aliens to gadgets
SYMBOL: views

H{ } clone views set-global

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
    } ;

: key-code ( event -- string )
    dup [keyCode] key-codes hash
    [ ] [ [charactersIgnoringModifiers] CF>string ] ?if ;

: event>gesture ( event -- gesture )
    dup [modifierFlags] modifiers modifier swap key-code
    add >list ;

: send-key-event ( view event -- )
    >r view world-focus r> dup event>gesture pick handle-gesture
    [ [characters] CF>string swap user-input ] [ 2drop ] if ;

: button... button >r view r> ;

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
        [ nip button... send-button-down ]
    }
    
    { "mouseUp:" "void" { "id" "SEL" "id" }
        [ nip button... send-button-up ]
    }
    
    { "rightMouseDown:" "void" { "id" "SEL" "id" }
        [ nip button... send-button-down ]
    }
    
    { "rightMouseUp:" "void" { "id" "SEL" "id" }
        [ nip button... send-button-up ]
    }
    
    { "otherMouseDown:" "void" { "id" "SEL" "id" }
        [ nip button... send-button-down ]
    }
    
    { "otherMouseUp:" "void" { "id" "SEL" "id" }
        [ nip button... send-button-up ]
    }
    
    { "scrollWheel:" "void" { "id" "SEL" "id" }
        [ nip [deltaY] 0 > >r view r> send-scroll-wheel ]
    }
    
    { "keyDown:" "void" { "id" "SEL" "id" }
        [ nip send-key-event ]
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

: <FactorWindow> ( gadget title -- window )
    >r <FactorView> r> <ViewWindow> dup [contentView] [release] ;

IN: gadgets

: redraw-world ( handle -- )
    world-handle 1 [setNeedsDisplay:] ;

: in-window ( gadget status dim title -- )
    >r <world> r> <FactorWindow> drop ;

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
            launchpad-window
            listener-window
            finish-launching
            event-loop
        ] with-cocoa
    ] with-freetype ;

IN: kernel

: default-shell running.app? "ui" "tty" ? ;
