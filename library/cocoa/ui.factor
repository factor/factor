! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays cocoa freetype gadgets-layouts
gadgets-listener gadgets-panes hashtables kernel lists math
namespaces objc objc-NSApplication objc-NSEvent objc-NSObject
objc-NSOpenGLView objc-NSView objc-NSWindow sequences threads ;

! Cocoa backend for Factor UI

IN: objc-FactorView
DEFER: FactorView

IN: gadgets

: repaint-handle ( handle -- ) 1 [setNeedsDisplay:] ;

IN: gadgets-cocoa

! Hash mapping aliens to gadgets
SYMBOL: views

H{ } clone views set-global

: register-view ( world -- )
    dup world-handle views get set-hash ;

: unregister-view ( world -- )
    world-handle views get remove-hash ;

: view ( handle -- world ) views get hash ;

: mouse-location ( event view -- loc )
    [
        swap [locationInWindow] f [convertPoint:fromView:]
        dup NSPoint-x swap NSPoint-y
    ] keep [frame] NSRect-h swap - 0 3array ;

: send-mouse-moved ( event view -- )
    [ mouse-location ] keep view move-hand ;

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
        [ 2drop [ view draw-world ] with-gl-view ]
    }
    
    { "mouseMoved:" "void" { "id" "SEL" "id" }
        [ nip swap send-mouse-moved ]
    }
    
    { "mouseDragged:" "void" { "id" "SEL" "id" }
        [ nip swap send-mouse-moved ]
    }
    
    { "rightMouseDragged:" "void" { "id" "SEL" "id" }
        [ nip swap send-mouse-moved ]
    }
    
    { "otherMouseDragged:" "void" { "id" "SEL" "id" }
        [ nip swap send-mouse-moved ]
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
        [ 2drop dup view-dim swap view set-gadget-dim ]
    }
    
    { "acceptsFirstResponder" "bool" { "id" "SEL" }
        [ 2drop 1 ]
    }
} { } define-objc-class

: <FactorView> ( gadget -- view )
    FactorView over rect-dim <GLView>
    dup "updateFactorGadgetSize:" add-resize-observer
    [ over set-world-handle register-view ] keep ;

: <FactorWindow> ( gadget title -- window )
    >r <FactorView> r> <ViewWindow> ;

IN: shells

: ui
    [
        [
            <listener> { 600 700 0 } <world>
            "Listener" <FactorWindow> drop
            [ clear listener-thread ] in-thread
            pane get request-focus
            finish-launching
            event-loop
        ] with-cocoa
    ] with-freetype ;
