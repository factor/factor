! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs cocoa kernel math cocoa.messages
cocoa.subclassing cocoa.classes cocoa.views cocoa.application
cocoa.pasteboard cocoa.types cocoa.windows sequences ui
ui.gadgets ui.gadgets.worlds ui.gestures core-foundation ;
IN: ui.cocoa.views

: send-mouse-moved ( view event -- )
    over >r mouse-location r> window move-hand fire-motion ;

: button ( event -- n )
    #! Cocoa -> Factor UI button mapping
    -> buttonNumber H{ { 0 1 } { 2 2 } { 1 3 } } at ;

: modifiers
    {
        { S+ HEX: 20000 }
        { C+ HEX: 40000 }
        { A+ HEX: 80000 }
        { M+ HEX: 100000 }
    } ;

: key-codes
    H{
        { 71 "CLEAR" }
        { 36 "RET" }
        { 76 "ENTER" }
        { 53 "ESC" }
        { 48 "TAB" }
        { 51 "BACKSPACE" }
        { 115 "HOME" }
        { 117 "DELETE" }
        { 119 "END" }
        { 122 "F1" }
        { 120 "F2" }
        { 99 "F3" }
        { 118 "F4" }
        { 96 "F5" }
        { 97 "F6" }
        { 98 "F7" }
        { 100 "F8" }
        { 123 "LEFT" }
        { 124 "RIGHT" }
        { 125 "DOWN" }
        { 126 "UP" }
        { 116 "PAGE_UP" }
        { 121 "PAGE_DOWN" }
    } ;

: key-code ( event -- string ? )
    dup -> keyCode key-codes at
    [ t ] [ -> charactersIgnoringModifiers CF>string f ] ?if ;

: event-modifiers ( event -- modifiers )
    -> modifierFlags modifiers modifier ;

: key-event>gesture ( event -- modifiers keycode action? )
    dup event-modifiers swap key-code ;

: send-key-event ( view event quot -- ? )
    >r key-event>gesture r> call swap window-focus
    send-gesture ; inline

: send-user-input ( view string -- )
    CF>string swap window-focus user-input ;

: interpret-key-event ( view event -- )
    NSArray swap -> arrayWithObject: -> interpretKeyEvents: ;

: send-key-down-event ( view event -- )
    2dup [ <key-down> ] send-key-event
    [ interpret-key-event ] [ 2drop ] if ;

: send-key-up-event ( view event -- )
    [ <key-up> ] send-key-event drop ;

: mouse-event>gesture ( event -- modifiers button )
    dup event-modifiers swap button ;

: send-button-down$ ( view event -- )
    [ mouse-event>gesture <button-down> ] 2keep
    mouse-location rot window send-button-down ;

: send-button-up$ ( view event -- )
    [ mouse-event>gesture <button-up> ] 2keep
    mouse-location rot window send-button-up ;

: send-wheel$ ( view event -- )
    over >r
    dup -> deltaX sgn neg over -> deltaY sgn neg 2array -rot
    mouse-location
    r> window send-wheel ;

: send-action$ ( view event gesture -- junk )
    >r drop window r> send-action f ;

: add-resize-observer ( observer object -- )
    >r "updateFactorGadgetSize:"
    "NSViewFrameDidChangeNotification" <NSString>
    r> add-observer ;

: string-or-nil? ( NSString -- ? )
    [ CF>string NSStringPboardType = ] [ t ] if* ;

: valid-service? ( gadget send-type return-type -- ? )
    over string-or-nil? over string-or-nil? and [
        drop [ gadget-selection? ] [ drop t ] if
    ] [
        3drop f
    ] if ;

: NSRect>rect ( NSRect world -- rect )
    >r dup NSRect-x over NSRect-y r>
    rect-dim second swap - 2array
    over NSRect-w rot NSRect-h 2array
    <rect> ;

: rect>NSRect ( rect world -- NSRect )
    over rect-loc first2 rot rect-dim second swap -
    rot rect-dim first2 <NSRect> ;

CLASS: {
    { +superclass+ "NSOpenGLView" }
    { +name+ "FactorView" }
    { +protocols+ { "NSTextInput" } }
}
! Events
{ "acceptsFirstMouse:" "bool" { "id" "SEL" "id" }
    [ 3drop 1 ]
}

{ "mouseEntered:" "void" { "id" "SEL" "id" }
    [ [ nip send-mouse-moved ] ui-try ]
}

{ "mouseExited:" "void" { "id" "SEL" "id" }
    [ [ 3drop forget-rollover ] ui-try ]
}

{ "mouseMoved:" "void" { "id" "SEL" "id" }
    [ [ nip send-mouse-moved ] ui-try ]
}

{ "mouseDragged:" "void" { "id" "SEL" "id" }
    [ [ nip send-mouse-moved ] ui-try ]
}

{ "rightMouseDragged:" "void" { "id" "SEL" "id" }
    [ [ nip send-mouse-moved ] ui-try ]
}

{ "otherMouseDragged:" "void" { "id" "SEL" "id" }
    [ [ nip send-mouse-moved ] ui-try ]
}

{ "mouseDown:" "void" { "id" "SEL" "id" }
    [ [ nip send-button-down$ ] ui-try ]
}

{ "mouseUp:" "void" { "id" "SEL" "id" }
    [ [ nip send-button-up$ ] ui-try ]
}

{ "rightMouseDown:" "void" { "id" "SEL" "id" }
    [ [ nip send-button-down$ ] ui-try ]
}

{ "rightMouseUp:" "void" { "id" "SEL" "id" }
    [ [ nip send-button-up$ ] ui-try ]
}

{ "otherMouseDown:" "void" { "id" "SEL" "id" }
    [ [ nip send-button-down$ ] ui-try ]
}

{ "otherMouseUp:" "void" { "id" "SEL" "id" }
    [ [ nip send-button-up$ ] ui-try ]
}

{ "scrollWheel:" "void" { "id" "SEL" "id" }
    [ [ nip send-wheel$ ] ui-try ]
}

{ "keyDown:" "void" { "id" "SEL" "id" }
    [ [ nip send-key-down-event ] ui-try ]
}

{ "keyUp:" "void" { "id" "SEL" "id" }
    [ [ nip send-key-up-event ] ui-try ]
}

{ "cut:" "id" { "id" "SEL" "id" }
    [ [ nip T{ cut-action } send-action$ ] ui-try ]
}

{ "copy:" "id" { "id" "SEL" "id" }
    [ [ nip T{ copy-action } send-action$ ] ui-try ]
}

{ "paste:" "id" { "id" "SEL" "id" }
    [ [ nip T{ paste-action } send-action$ ] ui-try ]
}

{ "delete:" "id" { "id" "SEL" "id" }
    [ [ nip T{ delete-action } send-action$ ] ui-try ]
}

{ "selectAll:" "id" { "id" "SEL" "id" }
    [ [ nip T{ select-all-action } send-action$ ] ui-try ]
}

{ "acceptsFirstResponder" "bool" { "id" "SEL" }
    [ 2drop 1 ]
}

! Services
{ "validRequestorForSendType:returnType:" "id" { "id" "SEL" "id" "id" }
    [
        ! We return either self or nil
        >r >r over window-focus r> r>
        valid-service? [ drop ] [ 2drop f ] if
    ]
}

{ "writeSelectionToPasteboard:types:" "bool" { "id" "SEL" "id" "id" }
    [
        CF>string-array NSStringPboardType swap member? [
            >r drop window-focus gadget-selection dup [
                r> set-pasteboard-string t
            ] [
                r> 2drop f
            ] if
        ] [
            3drop f
        ] if
    ]
}

{ "readSelectionFromPasteboard:" "bool" { "id" "SEL" "id" }
    [
        pasteboard-string dup [
            >r drop window-focus r> swap user-input t
        ] [
            3drop f
        ] if
    ]
}

! Text input
{ "insertText:" "void" { "id" "SEL" "id" }
    [ [ nip send-user-input ] ui-try ]
}

{ "hasMarkedText" "bool" { "id" "SEL" }
    [ 2drop 0 ]
}

{ "markedRange" "NSRange" { "id" "SEL" }
    [ 2drop 0 0 <NSRange> ]
}

{ "selectedRange" "NSRange" { "id" "SEL" }
    [ 2drop 0 0 <NSRange> ]
}

{ "setMarkedText:selectedRange:" "void" { "id" "SEL" "id" "NSRange" }
    [ 2drop 2drop ]
}

{ "unmarkText" "void" { "id" "SEL" }
    [ 2drop ]
}

{ "validAttributesForMarkedText" "id" { "id" "SEL" }
    [ 2drop NSArray -> array ]
}

{ "attributedSubstringFromRange:" "id" { "id" "SEL" "NSRange" }
    [ 3drop f ]
}

{ "characterIndexForPoint:" "uint" { "id" "SEL" "NSPoint" }
    [ 3drop 0 ]
}

{ "firstRectForCharacterRange:" "NSRect" { "id" "SEL" "NSRange" }
    [ 3drop 0 0 0 0 <NSRect> ]
}

{ "conversationIdentifier" "long" { "id" "SEL" }
    [ drop alien-address ]
}

! Initialization
{ "updateFactorGadgetSize:" "void" { "id" "SEL" "id" }
    [
        [
            2drop dup view-dim swap window set-gadget-dim
            ui-step
        ] ui-try
    ]
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
        dup window stop-world
        dup unregister-window
        dup remove-observer
        SUPER-> dealloc
    ]
} ;

: <FactorView> ( world -- view )
    FactorView over rect-dim <GLView> [ register-window ] keep ;

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "FactorWindowDelegate" }
}

{ "windowDidMove:" "void" { "id" "SEL" "id" }
    [
        2nip -> object
        dup window-content-rect NSRect-x-y 2array
        swap -> contentView window set-world-loc
    ]
}

{ "windowDidBecomeKey:" "void" { "id" "SEL" "id" }
    [
        2nip -> object -> contentView window focus-world
    ]
}

{ "windowDidResignKey:" "void" { "id" "SEL" "id" }
    [
        forget-rollover
        2nip -> object -> contentView window unfocus-world
    ]
} ;

: install-window-delegate ( window -- )
    FactorWindowDelegate install-delegate ;
