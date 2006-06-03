! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objc-classes
DEFER: FactorView

IN: cocoa
USING: arrays gadgets hashtables kernel math namespaces objc
opengl sequences ;

: <GLView> ( class dim -- view )
    >r -> alloc 0 0 r> first2 <NSRect>
    NSOpenGLView -> defaultPixelFormat
    -> initWithFrame:pixelFormat:
    dup 1 -> setPostsBoundsChangedNotifications:
    dup 1 -> setPostsFrameChangedNotifications: ;

: view-dim -> bounds dup NSRect-w swap NSRect-h 0 3array ;

: mouse-location ( view event -- loc )
    over >r
    -> locationInWindow f -> convertPoint:fromView:
    dup NSPoint-x swap NSPoint-y
    r> -> frame NSRect-h swap - 0 3array ;

: send-mouse-moved ( view event -- )
    over >r mouse-location r> window move-hand ;

: button ( event -- n )
    #! Cocoa -> Factor UI button mapping
    -> buttonNumber H{ { 0 1 } { 2 2 } { 1 3 } } hash ;

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
    dup -> keyCode key-codes hash
    [ ] [ -> charactersIgnoringModifiers CF>string ] ?if ;

: event>gesture ( event -- modifiers keycode )
    dup -> modifierFlags modifiers modifier swap key-code ;

: send-key-event ( view event quot -- )
    >r event>gesture r> call swap window world-focus
    handle-gesture ; inline

: send-user-input ( view event -- )
    -> characters CF>string swap window world-focus user-input ;

: send-key-down-event ( view event -- )
    2dup [ <key-down> ] send-key-event
    [ send-user-input ] [ 2drop ] if ;

: send-key-up-event ( view event -- )
    [ <key-up> ] send-key-event ;

: send-button-down$ ( view event -- )
    over >r button&loc r> window send-button-down ;

: send-button-up$ ( view event -- )
    over >r button&loc r> window send-button-up ;

: send-wheel$ ( view event -- )
    [ -> deltaY 0 > ] 2keep mouse-location
    rot window send-wheel ;

: send-action ( view event class -- f )
    >r drop window r> handle-action f ;

: add-resize-observer ( observer object -- )
    >r "updateFactorGadgetSize:"
    "NSViewFrameDidChangeNotification" <NSString>
    r> add-observer ;

"NSOpenGLView" "FactorView" {
    { "drawRect:" "void" { "id" "SEL" "NSRect" }
        [ 2drop window draw-world ]
    }
    
    { "acceptsFirstMouse:" "bool" { "id" "SEL" "id" }
        [ 3drop 1 ]
    }
    
    { "mouseEntered:" "void" { "id" "SEL" "id" }
        [ nip send-mouse-moved ]
    }
    
    { "mouseExited:" "void" { "id" "SEL" "id" }
        [ 3drop forget-rollover ]
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

    { "cut:" "id" { "id" "SEL" "id" }
        [ nip <cut-action> send-action ]
    }

    { "copy:" "id" { "id" "SEL" "id" }
        [ nip <copy-action> send-action ]
    }

    { "paste:" "id" { "id" "SEL" "id" }
        [ nip <paste-action> send-action ]
    }

    { "updateFactorGadgetSize:" "void" { "id" "SEL" "id" }
        [ 2drop dup view-dim swap window set-gadget-dim ]
    }
    
    { "acceptsFirstResponder" "bool" { "id" "SEL" }
        [ 2drop 1 ]
    }
    
    { "initWithFrame:pixelFormat:" "id" { "id" "SEL" "NSRect" "id" }
        [
            rot drop
            SUPER-> initWithFrame:pixelFormat:
            dup dup add-resize-observer
        ]
    }
    
    { "dealloc" "void" { "id" "SEL" }
        [
            drop
            dup window close-world
            dup unregister-window
            dup remove-observer
            SUPER-> dealloc
        ]
    }
} { } define-objc-class

: <FactorView> ( world -- view )
    FactorView over rect-dim <GLView> [ register-window ] keep ;
