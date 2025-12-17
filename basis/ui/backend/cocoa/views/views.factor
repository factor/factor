! Copyright (C) 2006, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data alien.strings
arrays assocs classes cocoa cocoa.application cocoa.classes
cocoa.pasteboard cocoa.runtime cocoa.subclassing cocoa.touchbar
cocoa.types cocoa.views combinators continuations
core-foundation.strings core-graphics core-graphics.types
core-text debugger io.encodings.string io.encodings.utf16
io.encodings.utf8 kernel literals math math.order math.parser
math.rectangles math.vectors namespaces opengl sequences
splitting threads ui.backend.cocoa.input-methods ui.commands
ui.gadgets ui.gadgets.editors ui.gadgets.line-support
ui.gadgets.private ui.gadgets.worlds ui.gestures ui.private
ui.theme ui.theme.switching words ;

IN: ui.backend.cocoa.views

SLOT: window

: send-mouse-moved ( view event -- )
    [ mouse-location ] [ drop window ] 2bi
    [ move-hand fire-motion yield ] [ drop ] if* ;

! Issue #1453
: button ( event -- n )
    ! Cocoa -> Factor UI button mapping
    -> buttonNumber {
        { 0 [ 1 ] }
        { 1 [ 3 ] }
        { 2 [ 2 ] }
        [ ]
    } case ;

CONSTANT: NSAlphaShiftKeyMask 0x10000
CONSTANT: NSShiftKeyMask      0x20000
CONSTANT: NSControlKeyMask    0x40000
CONSTANT: NSAlternateKeyMask  0x80000
CONSTANT: NSCommandKeyMask    0x100000
CONSTANT: NSNumericPadKeyMask 0x200000
CONSTANT: NSHelpKeyMask       0x400000
CONSTANT: NSFunctionKeyMask   0x800000

CONSTANT: modifiers {
        { S+ $ NSShiftKeyMask }
        { C+ $ NSControlKeyMask }
        { M+ $ NSCommandKeyMask }
        { A+ $ NSAlternateKeyMask }
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
    dup -> keyCode key-codes at or?
    [ t ] [ -> charactersIgnoringModifiers CF>string f ] if ;

: event-modifiers ( event -- modifiers )
    -> modifierFlags modifiers modifier ;

: key-event>gesture ( event -- modifiers keycode action? )
    [ event-modifiers ] [ key-code ] bi ;

: send-key-event ( view gesture -- )
    swap window [ propagate-key-gesture ] [ drop ] if* ;

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
    2tri
    [ send-button-down ] [ 2drop ] if* ;

: send-button-up$ ( view event -- )
    [ nip mouse-event>gesture <button-up> ]
    [ mouse-location ]
    [ drop window ]
    2tri
    [ send-button-up ] [ 2drop ] if* ;

: send-scroll$ ( view event -- )
    [ nip [ -> deltaX ] [ -> deltaY ] bi [ neg ] bi@ 2array ]
    [ mouse-location ]
    [ drop window ]
    2tri
    [ send-scroll ] [ 2drop ] if* ;

: send-action$ ( view event gesture -- )
    [ drop window ] dip over [ send-action ] [ 2drop ] if ;

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

: touchbar-commands ( -- commands/f gadget )
    world get-global [
        children>> [
            class-of "commands" word-prop
            "touchbar" of dup [ commands>> ] when
        ] map-find
    ] [ f f ] if* ;

TUPLE: send-touchbar-command target command ;

M: send-touchbar-command send-queued-gesture
    [ target>> ] [ command>> ] bi invoke-command ;

: touchbar-invoke-command ( n -- )
    [ touchbar-commands ] dip over [
        rot nth second
        send-touchbar-command queue-gesture notify-ui-thread
        yield
    ] [ 3drop ] if ;

IMPORT: NSAttributedString

<PRIVATE

:: >codepoint-index ( str utf16-index -- codepoint-index )
    0 utf16-index 2 * str utf16n encode subseq utf16n decode length ;

:: >utf16-index ( str codepoint-index -- utf16-index )
    0 codepoint-index str subseq utf16n encode length 2 /i ;

:: earlier-caret/mark ( editor -- loc )
    editor editor-caret :> caret
    editor editor-mark :> mark
    caret first mark first = [
        caret second mark second < [ caret ] [ mark ] if
    ] [
        caret first mark first < [ caret ] [ mark ] if
    ] if ;

:: make-preedit-underlines ( gadget text range -- underlines )
    f gadget preedit-selection-mode?<<
    { } clone :> underlines!
    text -> length :> text-length
    0 0 <NSRange> :> effective-range
    text -> string CF>string :> str
    str utf16n encode :> byte-16n
    0 :> cp-loc!
    "NSMarkedClauseSegment" <NSString> :> segment-attr
    [ effective-range [ location>> ] [ length>> ] bi + text-length < ] [
        text
        segment-attr
        effective-range [ location>> ] [ length>> ] bi +
        effective-range >c-ptr
        -> attribute:atIndex:effectiveRange: drop
        1 :> thickness!
        range location>> effective-range location>> = [
            2 thickness!
            t gadget preedit-selection-mode?<<
        ] when
        underlines
        effective-range [ location>> ] [ length>> ] bi over +
        [ str swap >codepoint-index ] bi@ swap - :> len
        cp-loc cp-loc len + dup cp-loc!
        2array thickness 2array
        suffix underlines!
    ] while 
    underlines length 1 = [
        underlines first first 2 2array 1array  ! thickness: 2
    ] [ underlines ] if ;

:: update-marked-text ( gadget str selectedRange replacementRange -- )
    replacementRange location>> NSNotFound = [
        gadget editor-caret first
        dup gadget editor-line
        [ 
            replacementRange location>>
            >codepoint-index
            2array gadget set-caret
        ] [
            replacementRange [ location>> ] [ length>> ] bi +
            >codepoint-index
            2array gadget set-mark
        ] 2bi
        gadget earlier-caret/mark dup
        gadget preedit-start<<
        0 1 2array v+ gadget preedit-end<<
    ] unless

    gadget preedit? [
        gadget remove-preedit-text
    ] when

    gadget earlier-caret/mark dup
    gadget preedit-start<<
    0 str length 2array v+ gadget preedit-end<<
    str gadget temp-im-input drop
    gadget preedit-start>>
    0 str selectedRange location>> >codepoint-index 2array v+
    dup gadget preedit-selected-start<<
    0
    selectedRange [ location>> ] [ length>> ] bi + selectedRange location>>
    [ str swap >codepoint-index ] bi@ -
    2array v+
    dup gadget preedit-selected-end<<
    dup gadget set-caret gadget set-mark
    gadget preedit-start>> gadget preedit-end>> = [
        gadget remove-preedit-info 
    ] when ;

: set-scale-factor ( n -- )
    [ 1.0 > ] keep f ? gl-scale-factor set-global
    cached-lines get-global clear-assoc ;

PRIVATE>

<CLASS: FactorView < NSOpenGLView
    COCOA-PROTOCOL: NSTextInputClient

    METHOD: void prepareOpenGL [
        self -> backingScaleFactor set-scale-factor
        self -> update
    ] ;

    METHOD: void reshape [
        self window :> window
        window [
            self view-dim window dim<<
        ] when
    ] ;

    ! TouchBar
    METHOD: void touchBarCommand0 [ 0 touchbar-invoke-command ] ;
    METHOD: void touchBarCommand1 [ 1 touchbar-invoke-command ] ;
    METHOD: void touchBarCommand2 [ 2 touchbar-invoke-command ] ;
    METHOD: void touchBarCommand3 [ 3 touchbar-invoke-command ] ;
    METHOD: void touchBarCommand4 [ 4 touchbar-invoke-command ] ;
    METHOD: void touchBarCommand5 [ 5 touchbar-invoke-command ] ;
    METHOD: void touchBarCommand6 [ 6 touchbar-invoke-command ] ;
    METHOD: void touchBarCommand7 [ 7 touchbar-invoke-command ] ;

    METHOD: id makeTouchBar [
        touchbar-commands drop [
            length 8 min <iota> [ number>string ] map
        ] [ { } ] if* self make-touchbar
    ] ;

    METHOD: id touchBar: id touchbar makeItemForIdentifier: id string [
        touchbar-commands drop [
            [ self string CF>string dup string>number ] dip nth
            second name>> "com-" ?head drop over
            "touchBarCommand" prepend make-NSTouchBar-button
        ] [ f ] if*
    ] ;

    ! Rendering
    METHOD: void drawRect: NSRect rect [
        self window [
            [ draw-world yield ] [ print-error drop ] recover
        ] when*
    ] ;

    ! Light/Dark Mode

    METHOD: void viewDidChangeEffectiveAppearance [
        self -> effectiveAppearance -> name [
            CF>string "NSAppearanceNameDarkAqua" =
            dark-theme light-theme ? switch-theme-if-default
        ] when*
    ] ;

    ! Events
    METHOD: char acceptsFirstMouse: id event [ 0 ] ;

    METHOD: void mouseEntered: id event [ self event send-mouse-moved ] ;

    METHOD: void mouseExited: id event [ forget-rollover ] ;

    METHOD: void mouseMoved: id event [ self event send-mouse-moved ] ;

    METHOD: void mouseDragged: id event [ self event send-mouse-moved ] ;

    METHOD: void rightMouseDragged: id event [ self event send-mouse-moved ] ;

    METHOD: void otherMouseDragged: id event [ self event send-mouse-moved ] ;

    METHOD: void mouseDown: id event [ self event send-button-down$ ] ;

    METHOD: void mouseUp: id event [ self event send-button-up$ ] ;

    METHOD: void rightMouseDown: id event [ self event send-button-down$ ] ;

    METHOD: void rightMouseUp: id event [ self event send-button-up$ ] ;

    METHOD: void otherMouseDown: id event [ self event send-button-down$ ] ;

    METHOD: void otherMouseUp: id event [ self event send-button-up$ ] ;

    METHOD: void scrollWheel: id event [ self event send-scroll$ ] ;

    METHOD: void keyDown: id event [ self event send-key-down-event ] ;

    METHOD: void keyUp: id event [ self event send-key-up-event ] ;

    METHOD: char validateUserInterfaceItem: id event
    [
        self window :> window
        window [
            window world-focus :> gadget
            gadget [
                gadget preedit? not [
                    window event -> action utf8 alien>string validate-action
                    [ >c-bool ] [ drop self event SUPER-> validateUserInterfaceItem: ] if
                ] [ 0 ] if
            ] [ 0 ] if
        ] [ 0 ] if
    ] ;

    METHOD: void undo: id event [ self event undo-action send-action$ ] ;

    METHOD: void redo: id event [ self event redo-action send-action$ ] ;

    METHOD: void cut: id event [ self event cut-action send-action$ ] ;

    METHOD: void copy: id event [ self event copy-action send-action$ ] ;

    METHOD: void paste: id event [ self event paste-action send-action$ ] ;

    METHOD: void delete: id event [ self event delete-action send-action$ ] ;

    METHOD: void selectAll: id event [ self event select-all-action send-action$ ] ;

    METHOD: void newDocument: id event [ self event new-action send-action$ ] ;

    METHOD: void openDocument: id event [ self event open-action send-action$ ] ;

    METHOD: void saveDocument: id event [ self event save-action send-action$ ] ;

    METHOD: void saveDocumentAs: id event [ self event save-as-action send-action$ ] ;

    METHOD: void revertDocumentToSaved: id event [ self event revert-action send-action$ ] ;

    ! Multi-touch gestures
    METHOD: void magnifyWithEvent: id event
    [
        self event
        dup -> deltaZ sgn {
            {  1 [ zoom-in-action send-action$ ] }
            { -1 [ zoom-out-action send-action$ ] }
            {  0 [ 2drop ] }
        } case
    ] ;

    METHOD: void swipeWithEvent: id event
    [
        self event
        dup -> deltaX sgn {
            {  1 [ left-action send-action$ ] }
            { -1 [ right-action send-action$ ] }
            {  0
                [
                    dup -> deltaY sgn {
                        {  1 [ up-action send-action$ ] }
                        { -1 [ down-action send-action$ ] }
                        {  0 [ 2drop ] }
                    } case
                ]
            }
        } case
    ] ;

    METHOD: char acceptsFirstResponder [ 1 ] ;

    ! Services
    METHOD: id validRequestorForSendType: id sendType returnType: id returnType
    [
        ! We return either self or nil
        self window [
            world-focus sendType returnType
            valid-service? [ self ] [ f ] if
        ] [ f ] if*
    ] ;

    METHOD: char writeSelectionToPasteboard: id pboard types: id types
    [
        NSStringPboardType types CF>string-array member? [
            self window [
                world-focus gadget-selection
                [ pboard set-pasteboard-string 1 ] [ 0 ] if*
            ] [ 0 ] if*
        ] [ 0 ] if
    ] ;

    METHOD: char readSelectionFromPasteboard: id pboard
    [
        self window :> window
        window [
            pboard pasteboard-string
            [ window user-input 1 ] [ 0 ] if*
        ] [ 0 ] if
    ] ;

    ! Text input
    METHOD: void insertText: id text replacementRange: NSRange replacementRange [
        self window :> window
        window [
            "" clone :> str!
            text NSString -> class -> isKindOfClass: 0 = not [
                text CF>string str!
            ] [
                text -> string CF>string str!
            ] if
            window world-focus :> gadget
            gadget [
                gadget support-input-methods? [
                    replacementRange location>> NSNotFound = [
                        gadget editor-caret first
                        dup gadget editor-line
                        [ 
                            replacementRange location>> >codepoint-index
                            2array gadget set-caret
                        ] [
                            replacementRange [ location>> ] [ length>> ] bi +
                            >codepoint-index
                            2array gadget set-mark
                        ] 2bi
                    ] unless
                    gadget preedit? [
                        gadget remove-preedit-text
                        gadget remove-preedit-info
                        str gadget user-input* drop
                        f gadget preedit-selection-mode?<<
                    ] [
                        str window user-input
                    ] if
                ] [ 
                    str window user-input
                ] if
            ] when
        ] when
    ] ;

    METHOD: char hasMarkedText [
        self window :> window
        window [
            window world-focus :> gadget
            gadget [
                gadget preedit? 1 0 ?
            ] [ 0 ] if
        ] [ 0 ] if
    ] ;

    METHOD: NSRange markedRange [
        self window :> window
        window [
            window world-focus :> gadget
            gadget [
                gadget preedit? [
                    gadget preedit-start>> second
                    gadget preedit-end>> second < [
                        gadget preedit-start>> first gadget editor-line :> str
                        gadget preedit-start>> second           ! location
                        gadget preedit-end>> second
                        [ str swap >utf16-index ] bi@ over -    ! length
                    ] [ NSNotFound 0 ] if
                ] [ NSNotFound 0 ] if
            ] [ NSNotFound 0 ] if
        ] [ NSNotFound 0 ] if
        <NSRange>
    ] ;

    METHOD: NSRange selectedRange [
        self window :> window
        window [
            window world-focus :> gadget
            gadget [
                gadget support-input-methods? [
                    gadget editor-caret first gadget editor-line :> str
                    gadget preedit? [
                        str
                        gadget preedit-selected-start>> second
                        gadget preedit-start>> second
                        - >utf16-index                        ! location
                        gadget preedit-selected-end>> second
                        gadget preedit-selected-start>> second
                        [ str swap >utf16-index ] bi@ -       ! length
                    ] [
                        str gadget editor-caret second >utf16-index 0
                    ] if
                ] [ 0 0 ] if
            ] [ 0 0 ] if
        ] [ 0 0 ] if 
        <NSRange>
    ] ;

    METHOD: void setMarkedText: id text selectedRange: NSRange selectedRange
                                     replacementRange: NSRange replacementRange [
        self window :> window
        window [
            window world-focus :> gadget
            gadget [
                { } clone :> underlines!
                "" clone :> str!
                text NSString -> class -> isKindOfClass: 0 = not [
                    text CF>string str!
                ] [
                    text -> string CF>string str!
                    gadget support-input-methods? [
                        gadget text selectedRange make-preedit-underlines underlines!
                    ] when
                ] if
                gadget support-input-methods? [
                    gadget str selectedRange replacementRange update-marked-text
                    underlines gadget preedit-underlines<<
                ] when
            ] when
        ] when
    ] ;

    METHOD: void unmarkText [
        self window :> window
        window [
            window world-focus :> gadget
            gadget [
                gadget support-input-methods? [
                    gadget preedit? [
                        gadget {
                            [ preedit-start>> second ]
                            [ preedit-end>> second ]
                            [ preedit-start>> first ]
                            [ editor-line ]
                        } cleave subseq
                        gadget remove-preedit-text
                        gadget remove-preedit-info
                        gadget user-input* drop
                    ] when
                    f gadget preedit-selection-mode?<<
                ] when
            ] when
        ] when
    ] ;

    METHOD: id validAttributesForMarkedText [
        NSArray "NSMarkedClauseSegment" <NSString> -> arrayWithObject:
    ] ;

    METHOD: id attributedSubstringForProposedRange: NSRange aRange
                                       actualRange: id actualRange [ f ] ;

    METHOD: NSUInteger characterIndexForPoint: NSPoint point [ 0 ] ;

    METHOD: NSRect firstRectForCharacterRange: NSRange aRange
                                  actualRange: NSRange actualRange [
        self window :> window
        window [
            window world-focus :> gadget
            gadget [
                gadget support-input-methods? [
                    gadget editor-caret first gadget editor-line :> str
                    str aRange location>> >codepoint-index :> start-pos
                    gadget editor-caret first start-pos 2array gadget loc>x
                    gadget caret-loc second gadget caret-dim second + 
                    2array                     ! character pos
                    gadget screen-loc v+       ! + gadget pos
                    { 1 -1 } v*
                    window handle>> window>> dup -> frame -> contentRectForFrameRect:
                    CGRect-top-left 2array v+  ! + window pos
                    first2 [ >fixnum ] bi@ 0 gadget line-height >fixnum
                ] [ 0 0 0 0 ] if
            ] [ 0 0 0 0 ] if
        ] [ 0 0 0 0 ] if
        <CGRect>
    ] ;

    METHOD: void doCommandBySelector: SEL selector [ ] ;

    ! Initialization
    METHOD: id initWithFrame: NSRect frame pixelFormat: id pixelFormat
    [
        self frame pixelFormat SUPER-> initWithFrame:pixelFormat:
    ] ;

    METHOD: char isOpaque [ 0 ] ;

    METHOD: void dealloc
    [
        self remove-observer
        self SUPER-> dealloc
    ] ;
;CLASS>

: sync-refresh-to-screen ( GLView -- )
    -> openGLContext -> CGLContextObj NSOpenGLCPSwapInterval 1 int <ref>
    CGLSetParameter drop ;

: <FactorView> ( dim pixel-format -- view )
    [ FactorView ] 2dip <GLView>
    [ 1 -> setWantsBestResolutionOpenGLSurface: ] keep
    [ -> backingScaleFactor set-scale-factor ] keep
    [ sync-refresh-to-screen ] keep ;

: save-position ( world window -- )
    -> frame CGRect-top-left 2array >>window-loc drop ;

<CLASS: FactorWindowDelegate < NSObject

    METHOD: void windowDidMove: id notification
    [
        notification -> object -> contentView window
        [ notification -> object save-position ] when*
    ] ;

    METHOD: void windowDidBecomeKey: id notification
    [
        notification -> object -> contentView window
        [ focus-world ] when*
    ] ;

    METHOD: void windowDidResignKey: id notification
    [
        forget-rollover
        notification -> object -> contentView :> view
        view window :> window
        window [
            view -> isInFullScreenMode 0 =
            [ window unfocus-world ] when
        ] when
    ] ;

    METHOD: char windowShouldClose: id notification [ 1 ] ;

    METHOD: void windowWillClose: id notification
    [
        notification -> object -> contentView
        [ window ungraft ] [ unregister-window ] bi
    ] ;

    METHOD: void windowDidChangeBackingProperties: id notification
    [
        notification -> object -> backingScaleFactor set-scale-factor
    ] ;
;CLASS>

: install-window-delegate ( window -- )
    FactorWindowDelegate install-delegate ;
