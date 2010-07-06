! Copyright (C) 2006, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
arrays assocs cocoa kernel math cocoa.messages cocoa.subclassing
cocoa.classes cocoa.views cocoa.application cocoa.pasteboard
cocoa.runtime cocoa.types cocoa.windows sequences io.encodings.utf8
ui ui.private ui.gadgets ui.gadgets.private ui.gadgets.worlds ui.gestures
core-foundation.strings core-graphics core-graphics.types threads
combinators math.rectangles ;
IN: ui.backend.cocoa.views

: send-mouse-moved ( view event -- )
    [ mouse-location ] [ drop window ] 2bi move-hand fire-motion yield ;

: button ( event -- n )
    #! Cocoa -> Factor UI button mapping
    -> buttonNumber H{ { 0 1 } { 2 2 } { 1 3 } } at ;

CONSTANT: modifiers
    {
        { S+ HEX: 20000 }
        { C+ HEX: 40000 }
        { A+ HEX: 100000 }
        { M+ HEX: 80000 }
    }

CONSTANT: key-codes
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
    }

: key-code ( event -- string ? )
    dup -> keyCode key-codes at
    [ t ] [ -> charactersIgnoringModifiers CF>string f ] ?if ;

: event-modifiers ( event -- modifiers )
    -> modifierFlags modifiers modifier ;

: key-event>gesture ( event -- modifiers keycode action? )
    [ event-modifiers ] [ key-code ] bi ;

: send-key-event ( view gesture -- )
    swap window propagate-key-gesture ;

: interpret-key-event ( view event -- )
    NSArray swap -> arrayWithObject: -> interpretKeyEvents: ;

: send-key-down-event ( view event -- )
    [ key-event>gesture <key-down> send-key-event ]
    [ interpret-key-event ]
    2bi ;

: send-key-up-event ( view event -- )
    key-event>gesture <key-up> send-key-event ;

: mouse-event>gesture ( event -- modifiers button )
    [ event-modifiers ] [ button ] bi ;

: send-button-down$ ( view event -- )
    [ nip mouse-event>gesture <button-down> ]
    [ mouse-location ]
    [ drop window ]
    2tri send-button-down ;

: send-button-up$ ( view event -- )
    [ nip mouse-event>gesture <button-up> ]
    [ mouse-location ]
    [ drop window ]
    2tri send-button-up ;

: send-scroll$ ( view event -- )
    [ nip [ -> deltaX ] [ -> deltaY ] bi [ neg ] bi@ 2array ]
    [ mouse-location ]
    [ drop window ]
    2tri send-scroll ;

: send-action$ ( view event gesture -- junk )
    [ drop window ] dip send-action f ;

: add-resize-observer ( observer object -- )
    [
        "updateFactorGadgetSize:"
        "NSViewFrameDidChangeNotification" <NSString>
    ] dip add-observer ;

: string-or-nil? ( NSString -- ? )
    [ CF>string NSStringPboardType = ] [ t ] if* ;

: valid-service? ( gadget send-type return-type -- ? )
    2dup [ string-or-nil? ] [ string-or-nil? ] bi* and
    [ drop [ gadget-selection? ] [ drop t ] if ] [ 3drop f ] if ;

: NSRect>rect ( NSRect world -- rect )
    [ [ [ CGRect-x ] [ CGRect-y ] bi ] [ dim>> second ] bi* swap - 2array ]
    [ drop [ CGRect-w ] [ CGRect-h ] bi 2array ]
    2bi <rect> ;

: rect>NSRect ( rect world -- NSRect )
    [ [ loc>> first2 ] [ dim>> second ] bi* swap - ]
    [ drop dim>> first2 ]
    2bi <CGRect> ;

CONSTANT: selector>action H{
    { "undo:" undo-action }
    { "redo:" redo-action }
    { "cut:" cut-action }
    { "copy:" copy-action }
    { "paste:" paste-action }
    { "delete:" delete-action }
    { "selectAll:" select-all-action }
    { "newDocument:" new-action }
    { "openDocument:" open-action }
    { "saveDocument:" save-action }
    { "saveDocumentAs:" save-as-action }
    { "revertDocumentToSaved:" revert-action }
}

: validate-action ( world selector -- ? validated? )
    selector>action at
    [ swap world-focus parents-handle-gesture? t ] [ drop f f ] if* ;

CLASS: {
    { +superclass+ "NSOpenGLView" }
    { +name+ "FactorView" }
    { +protocols+ { "NSTextInput" } }
}

! Rendering
METHOD: void drawRect: NSRect rect [ self window draw-world ]

! Events
METHOD: char acceptsFirstMouse: id event [ 1 ]

METHOD: void mouseEntered: id event [ self event send-mouse-moved ]

METHOD: void mouseExited: id event [ forget-rollover ]

METHOD: void mouseMoved: id event [ self event send-mouse-moved ]

METHOD: void mouseDragged: id event [ self event send-mouse-moved ]

METHOD: void rightMouseDragged: id event [ self event send-mouse-moved ]

METHOD: void otherMouseDragged: id event [ self event send-mouse-moved ]

METHOD: void mouseDown: id event [ self event send-button-down$ ]

METHOD: void mouseUp: id event [ self event send-button-up$ ]

METHOD: void rightMouseDown: id event [ self event send-button-down$ ]

METHOD: void rightMouseUp: id event [ self event send-button-up$ ]

METHOD: void otherMouseDown: id event [ self event send-button-down$ ]

METHOD: void otherMouseUp: id event [ self event send-button-up$ ]

METHOD: void scrollWheel: id event [ self event send-scroll$ ]

METHOD: void keyDown: id event [ self event send-key-down-event ]

METHOD: void keyUp: id event [ self event send-key-up-event ]

METHOD: char validateUserInterfaceItem: id event
[
    self window
    event -> action utf8 alien>string validate-action
    [ >c-bool ] [ drop self event SUPER-> validateUserInterfaceItem: ] if
]

METHOD: id undo: id event [ self event undo-action send-action$ ]

METHOD: id redo: id event [ self event redo-action send-action$ ]

METHOD: id cut: id event [ self event cut-action send-action$ ]

METHOD: id copy: id event [ self event copy-action send-action$ ]

METHOD: id paste: id event [ self event paste-action send-action$ ]

METHOD: id delete: id event [ self event delete-action send-action$ ]

METHOD: id selectAll: id event [ self event select-all-action send-action$ ]

METHOD: id newDocument: id event [ self event new-action send-action$ ]

METHOD: id openDocument: id event [ self event open-action send-action$ ]

METHOD: id saveDocument: id event [ self event save-action send-action$ ]

METHOD: id saveDocumentAs: id event [ self event save-as-action send-action$ ]

METHOD: id revertDocumentToSaved: id event [ self event revert-action send-action$ ]

! Multi-touch gestures
METHOD: void magnifyWithEvent: id event
[
    self event
    dup -> deltaZ sgn {
        {  1 [ zoom-in-action send-action$ drop ] }
        { -1 [ zoom-out-action send-action$ drop ] }
        {  0 [ 2drop ] }
    } case
]

METHOD: void swipeWithEvent: id event
[
    self event
    dup -> deltaX sgn {
        {  1 [ left-action send-action$ drop ] }
        { -1 [ right-action send-action$ drop ] }
        {  0
            [
                dup -> deltaY sgn {
                    {  1 [ up-action send-action$ drop ] }
                    { -1 [ down-action send-action$ drop ] }
                    {  0 [ 2drop ] }
                } case
            ]
        }
    } case
]

METHOD: char acceptsFirstResponder [ 1 ]

! Services
METHOD: id validRequestorForSendType: id sendType returnType: id returnType
[
    ! We return either self or nil
    self window world-focus sendType returnType
    valid-service? [ self ] [ f ] if
]

METHOD: char writeSelectionToPasteboard: id pboard types: id types
[
    NSStringPboardType types CF>string-array member? [
        self window world-focus gadget-selection
        [ pboard set-pasteboard-string 1 ] [ 0 ] if*
    ] [ 0 ] if
]

METHOD: char readSelectionFromPasteboard: id pboard
[
    pboard pasteboard-string
    [ self window user-input 1 ] [ 0 ] if*
]

! Text input
METHOD: void insertText: id text
[ text CF>string self window user-input ]

METHOD: char hasMarkedText [ 0 ]

METHOD: NSRange markedRange [ 0 0 <NSRange> ]

METHOD: NSRange selectedRange [ 0 0 <NSRange> ]

METHOD: void setMarkedText: id text selectedRange: NSRange range [ ]

METHOD: void unmarkText [ ]

METHOD: id validAttributesForMarkedText [ NSArray -> array ]

METHOD: id attributedSubstringFromRange: NSRange range [ f ]

METHOD: NSUInteger characterIndexForPoint: NSPoint point [ 0 ]

METHOD: NSRect firstRectForCharacterRange: NSRange range [ 0 0 0 0 <CGRect> ]

METHOD: NSInteger conversationIdentifier [ self alien-address ]

! Initialization
METHOD: void updateFactorGadgetSize: id notification
[ self view-dim self window dim<< yield ]

METHOD: void doCommandBySelector: SEL selector [ ]

METHOD: id initWithFrame: NSRect frame pixelFormat: id pixelFormat
[
    self frame pixelFormat SUPER-> initWithFrame:pixelFormat:
    dup dup add-resize-observer
]

METHOD: char isOpaque [ 0 ]

METHOD: void dealloc
[
    self remove-observer
    self SUPER-> dealloc
] ;

: sync-refresh-to-screen ( GLView -- )
    -> openGLContext -> CGLContextObj NSOpenGLCPSwapInterval 1 <int>
    CGLSetParameter drop ;

: <FactorView> ( dim pixel-format -- view )
    [ FactorView ] 2dip <GLView> [ sync-refresh-to-screen ] keep ;

: save-position ( world window -- )
    -> frame CGRect-top-left 2array >>window-loc drop ;

CLASS: {
    { +name+ "FactorWindowDelegate" }
    { +superclass+ "NSObject" }
}

METHOD: void windowDidMove: id notification
[
    notification -> object -> contentView window
    notification -> object save-position
]

METHOD: void windowDidBecomeKey: id notification
[
    notification -> object -> contentView window
    focus-world
]

METHOD: void windowDidResignKey: id notification
[
    forget-rollover
    notification -> object -> contentView
    dup -> isInFullScreenMode 0 =
    [ window [ unfocus-world ] when* ] [ drop ] if
]

METHOD: char windowShouldClose: id notification [ 1 ]

METHOD: void windowWillClose: id notification
[
    notification -> object -> contentView
    [ window ungraft ] [ unregister-window ] bi
] ;

: install-window-delegate ( window -- )
    FactorWindowDelegate install-delegate ;
