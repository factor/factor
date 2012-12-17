! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data cocoa cocoa.application
cocoa.classes cocoa.nibs cocoa.pasteboard cocoa.runtime
cocoa.subclassing cocoa.views cocoa.windows combinators
core-foundation.run-loop core-graphics core-graphics.types formatting
generalizations io.thread kernel libc literals locals math
math.bitwise math.rectangles namespaces sequences syslog system
threads ui ui.backend ui.backend.cocoa.views ui.clipboards
ui.gadgets.worlds ui.pixel-formats ui.pixel-formats.private ui.private
;

IN: ui.backend.cocoa

TUPLE: handle ;
TUPLE: window-handle < handle view window ;
TUPLE: offscreen-handle < handle context buffer ;

C: <window-handle> window-handle
C: <offscreen-handle> offscreen-handle

SINGLETON: cocoa-ui-backend

PIXEL-FORMAT-ATTRIBUTE-TABLE: NSOpenGLPFA { } H{
    { double-buffered { $ NSOpenGLPFADoubleBuffer } }
    { stereo { $ NSOpenGLPFAStereo } }
    { offscreen { $ NSOpenGLPFAOffScreen } }
    { fullscreen { $ NSOpenGLPFAFullScreen } }
    { windowed { $ NSOpenGLPFAWindow } }
    { accelerated { $ NSOpenGLPFAAccelerated } }
    { software-rendered { $ NSOpenGLPFARendererID $ kCGLRendererGenericFloatID } }
    { backing-store { $ NSOpenGLPFABackingStore } }
    { multisampled { $ NSOpenGLPFAMultisample } }
    { supersampled { $ NSOpenGLPFASupersample } }
    { sample-alpha { $ NSOpenGLPFASampleAlpha } }
    { color-float { $ NSOpenGLPFAColorFloat } }
    { color-bits { $ NSOpenGLPFAColorSize } }
    { alpha-bits { $ NSOpenGLPFAAlphaSize } }
    { accum-bits { $ NSOpenGLPFAAccumSize } }
    { depth-bits { $ NSOpenGLPFADepthSize } }
    { stencil-bits { $ NSOpenGLPFAStencilSize } }
    { aux-buffers { $ NSOpenGLPFAAuxBuffers } }
    { sample-buffers { $ NSOpenGLPFASampleBuffers } }
    { samples { $ NSOpenGLPFASamples } }
}

M: cocoa-ui-backend (make-pixel-format)
    nip >NSOpenGLPFA-int-array
    NSOpenGLPixelFormat -> alloc swap -> initWithAttributes: ;

M: cocoa-ui-backend (free-pixel-format)
    handle>> -> release ;

M: cocoa-ui-backend (pixel-format-attribute)
    [ handle>> ] [ >NSOpenGLPFA ] bi*
    [ drop f ]
    [
        first
        { int } [ swap 0 -> getValues:forAttribute:forVirtualScreen: ]
        with-out-parameters
    ] if-empty ;

TUPLE: pasteboard handle ;

C: <pasteboard> pasteboard

M: pasteboard clipboard-contents
    handle>> pasteboard-string ;

M: pasteboard set-clipboard-contents
    handle>> set-pasteboard-string ;

: init-clipboard ( -- )
    NSPasteboard -> generalPasteboard <pasteboard>
    clipboard set-global
    <clipboard> selection set-global ;

: world>NSRect ( world -- NSRect )
    [ 0 0 ] dip dim>> first2 <CGRect> ;

FROM: ui.private => windows ;
: auto-position ( window loc -- )
    #! Note: if this is the initial window, the length of the windows
    #! vector should be 1, since (open-window) calls auto-position
    #! after register-window.
    dup "window-loc: %@" sprintf SYSLOG_TEST
    dup { 0 0 } = [
        first2 <CGPoint> -> setFrameTopLeftPoint:
        ! windows get-global length 1 <= [ drop ] [
        !     windows get-global last second window-loc>>
        !     dup "window-loc: %@" sprintf SYSLOG_TEST
        !     dupd first2 <CGPoint> -> cascadeTopLeftFromPoint:
        !     -> setFrameTopLeftPoint:
        ! ] if
    ] [ first2 <CGPoint> -> setFrameTopLeftPoint: ] if ;

M: cocoa-ui-backend set-title ( string world -- )
    handle>> window>> swap <NSString> -> setTitle: ;

: enter-fullscreen ( world -- )
    handle>> view>>
    NSScreen -> mainScreen
    f -> enterFullScreenMode:withOptions:
    drop ;

: exit-fullscreen ( world -- )
    handle>>
    [ view>> f -> exitFullScreenModeWithOptions: ] 
    [ [ window>> ] [ view>> ] bi -> makeFirstResponder: drop ] bi ;

M: cocoa-ui-backend (set-fullscreen) ( world ? -- )
    [ enter-fullscreen ] [ exit-fullscreen ] if ;

M: cocoa-ui-backend (fullscreen?) ( world -- ? )
    handle>> view>> -> isInFullScreenMode zero? not ;

CONSTANT: window-control>styleMask
    H{
        { close-button $ NSClosableWindowMask }
        { minimize-button $ NSMiniaturizableWindowMask }
        { maximize-button 0 }
        { resize-handles $ NSResizableWindowMask }
        { small-title-bar $[ NSTitledWindowMask NSUtilityWindowMask bitor ] }
        { normal-title-bar $ NSTitledWindowMask }
        { textured-background $ NSTexturedBackgroundWindowMask }
    }

: world>styleMask ( world -- n )
    window-controls>> window-control>styleMask symbols>flags ;

: make-context-transparent ( view -- )
    -> openGLContext
    0 int <ref> NSOpenGLCPSurfaceOpacity -> setValues:forParameter: ;

M:: cocoa-ui-backend (open-window) ( world -- )
    world [ [ dim>> ] dip <FactorView> ]
    with-world-pixel-format :> view
    world window-controls>> textured-background swap member-eq?
    [ view make-context-transparent ] when
    view world [ world>NSRect ] [ world>styleMask ] bi <ViewWindow> :> window
    view -> release
    world view register-window
    window world window-loc>> auto-position
    world window save-position
    window install-window-delegate
    view window <window-handle> world handle<<
    window f -> makeKeyAndOrderFront: ;

M: cocoa-ui-backend (close-window) ( handle -- )
    [
        view>> dup -> isInFullScreenMode zero?
        [ drop ]
        [ f -> exitFullScreenModeWithOptions: ] if
    ] [ window>> -> release ] bi ;

M: cocoa-ui-backend (grab-input) ( handle -- )
    0 CGAssociateMouseAndMouseCursorPosition drop
    CGMainDisplayID CGDisplayHideCursor drop
    window>> -> frame CGRect>rect rect-center
    NSScreen -> screens 0 -> objectAtIndex: -> frame CGRect-h
    [ drop first ] [ swap second - ] 2bi <CGPoint>
    [ GetCurrentButtonState zero? not ] [ yield ] while
    CGWarpMouseCursorPosition drop ;

M: cocoa-ui-backend (ungrab-input) ( handle -- )
    drop
    CGMainDisplayID CGDisplayShowCursor drop
    1 CGAssociateMouseAndMouseCursorPosition drop ;

M: cocoa-ui-backend close-window ( gadget -- )
    find-world [
        handle>> [
            window>> -> close
        ] when*
    ] when* ;

M: cocoa-ui-backend raise-window* ( world -- )
    handle>> [
        window>> dup f -> orderFront: -> makeKeyWindow
        NSApp 1 -> activateIgnoringOtherApps:
    ] when* ;

: pixel-size ( pixel-format -- size )
    color-bits (pixel-format-attribute) -3 shift ;

: offscreen-buffer ( world pixel-format -- alien w h pitch )
    [ dim>> first2 ] [ pixel-size ] bi*
    { [ * * malloc ] [ 2drop ] [ drop nip ] [ nip * ] } 3cleave ;

:: gadget-offscreen-context ( world -- context buffer )
    world [
        nip :> pf
        NSOpenGLContext -> alloc pf handle>> f -> initWithFormat:shareContext:
        dup world pf offscreen-buffer
        4 npick [ -> setOffScreen:width:height:rowbytes: ] dip
    ] with-world-pixel-format ;

M: cocoa-ui-backend (open-offscreen-buffer) ( world -- )
    dup gadget-offscreen-context <offscreen-handle> >>handle drop ;

M: cocoa-ui-backend (close-offscreen-buffer) ( handle -- )
    [ context>> -> release ]
    [ buffer>> free ] bi ;

GENERIC: (gl-context) ( handle -- context )
M: window-handle (gl-context) view>> -> openGLContext ;
M: offscreen-handle (gl-context) context>> ;

M: handle select-gl-context ( handle -- )
    (gl-context) -> makeCurrentContext ;

M: handle flush-gl-context ( handle -- )
    (gl-context) -> flushBuffer ;

M: cocoa-ui-backend offscreen-pixels ( world -- alien w h )
    [ handle>> buffer>> ] [ dim>> first2 neg ] bi ;

M: cocoa-ui-backend beep ( -- )
    NSBeep ;

M: cocoa-ui-backend resize-window [ handle>> window>> ] [ first2 ] bi* <CGSize> -> setContentSize: ;

M: cocoa-ui-backend system-alert
    NSAlert -> alloc -> init -> autorelease [
        {
            [ swap <NSString> -> setInformativeText: ]
            [ swap <NSString> -> setMessageText: ]
            [ "OK" <NSString> -> addButtonWithTitle: drop ]
            [ -> runModal drop ]
        } cleave
    ] [ 2drop ] if* ;

CLASS: FactorApplicationDelegate < NSObject
[
    METHOD: void applicationDidUpdate: id obj
    [ reset-run-loop ]
]

: install-app-delegate ( -- )
    NSApp FactorApplicationDelegate install-delegate ;

SYMBOL: cocoa-startup-hook

cocoa-startup-hook [
    [ "MiniFactor.nib" load-nib install-app-delegate ]
] initialize

M: cocoa-ui-backend (with-ui)
    "UI" assert.app [
        [
            init-clipboard
            cocoa-startup-hook get call( -- )
            start-ui
            stop-io-thread
            init-thread-timer
            reset-run-loop
            NSApp -> run
        ] ui-running
    ] with-cocoa ;

cocoa-ui-backend ui-backend set-global

M: cocoa-ui-backend ui-backend-available?
    running.app? ;

