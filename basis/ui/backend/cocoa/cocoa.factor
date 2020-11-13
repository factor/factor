! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays assocs classes
cocoa cocoa.application cocoa.classes cocoa.messages cocoa.nibs
cocoa.pasteboard cocoa.runtime cocoa.subclassing cocoa.types
cocoa.views cocoa.windows combinators command-line
core-foundation core-foundation.run-loop core-graphics
core-graphics.types destructors fry generalizations io.thread
kernel libc literals locals math math.bitwise math.rectangles
memory namespaces sequences threads ui colors ui.backend
ui.backend.cocoa.views ui.clipboards ui.gadgets
ui.gadgets.worlds ui.pixel-formats ui.private words.symbol ;
IN: ui.backend.cocoa

TUPLE: window-handle view window ;

C: <window-handle> window-handle

SINGLETON: cocoa-ui-backend

CONSTANT: attrib-table H{
    { double-buffered { $ NSOpenGLPFADoubleBuffer } }
    { stereo { $ NSOpenGLPFAStereo } }
    { offscreen { $ NSOpenGLPFAOffScreen } }
    { fullscreen { $ NSOpenGLPFAFullScreen } }
    { windowed { $ NSOpenGLPFAWindow } }
    { accelerated { $ NSOpenGLPFAAccelerated } }
    { software-rendered {
          $ NSOpenGLPFARendererID
          $ kCGLRendererGenericFloatID }
    }
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
    nip { } attrib-table pixel-format-attributes>int-array
    NSOpenGLPixelFormat send: alloc swap send: \initWithAttributes: ;

M: cocoa-ui-backend (free-pixel-format)
    handle>> send: release ;

TUPLE: pasteboard handle ;

C: <pasteboard> pasteboard

M: pasteboard clipboard-contents
    handle>> pasteboard-string ;

M: pasteboard set-clipboard-contents
    handle>> set-pasteboard-string ;

: init-clipboard ( -- )
    NSPasteboard send: generalPasteboard <pasteboard>
    clipboard set-global
    <clipboard> selection set-global ;

: world>NSRect ( world -- NSRect )
    [ 0 0 ] dip dim>> first2 <CGRect> ;

: auto-position ( window loc -- )
    ! Note: if this is the initial window, the length of the windows
    ! vector should be 1, since (open-window) calls auto-position
    ! after register-window.
    dup { 0 0 } = [
        drop
        worlds get-global length 1 <= [ send: center ] [
            worlds get-global last second window-loc>>
            dupd first2 <CGPoint> send: \cascadeTopLeftFromPoint:
            send: \setFrameTopLeftPoint:
        ] if
    ] [ first2 <CGPoint> send: \setFrameTopLeftPoint: ] if ;

M: cocoa-ui-backend set-title ( string world -- )
    handle>> window>> swap <NSString> send: \setTitle: ;

: enter-fullscreen ( world -- )
    handle>> view>>
    NSScreen send: mainScreen
    f send: \enterFullScreenMode:withOptions:
    drop ;

: exit-fullscreen ( world -- )
    handle>>
    [ view>> f send: \exitFullScreenModeWithOptions: ]
    [ [ window>> ] [ view>> ] bi send: \makeFirstResponder: drop ] bi ;

M: cocoa-ui-backend (set-fullscreen)
    [ enter-fullscreen ] [ exit-fullscreen ] if ;

! Handle can be ``f`` sometimes, like if you hold ``w``
! when you loop in the debugger.
M: cocoa-ui-backend (fullscreen?) ( world -- ? )
    handle>> [ view>> send: isInFullScreenMode zero? not ] [ f ] if* ;

! XXX: Until someone tests OSX with a tiling window manager,
! dialog-window is the same as normal-title-window
CONSTANT: window-control>styleMask
    H{
        { close-button $ NSClosableWindowMask }
        { minimize-button $ NSMiniaturizableWindowMask }
        { maximize-button 0 }
        { resize-handles $ NSResizableWindowMask }
        { small-title-bar flags{ NSTitledWindowMask NSUtilityWindowMask } }
        { textured-background $ NSTexturedBackgroundWindowMask }
        { normal-title-bar $ NSTitledWindowMask }
        { dialog-window $ NSTitledWindowMask }
    }

: world>styleMask ( world -- n )
    window-controls>> window-control>styleMask symbols>flags ;

: make-context-transparent ( view -- )
    send: openGLContext
    0 int <ref> NSOpenGLCPSurfaceOpacity send: \setValues:forParameter: ;

M:: cocoa-ui-backend (open-window) ( world -- )
    world [ [ dim>> ] dip <FactorView> ]
    with-world-pixel-format :> view
    world window-controls>> textured-background swap member-eq?
    [ view make-context-transparent ] when
    view world [ world>NSRect ] [ world>styleMask ] bi <ViewWindow> :> window
    view send: release
    world view register-window
    window world window-loc>> auto-position
    world window save-position
    window install-window-delegate
    view window <window-handle> world handle<<
    window f send: \makeKeyAndOrderFront:
    t world active?<< ;

M: cocoa-ui-backend (close-window)
    [
        view>> dup send: isInFullScreenMode zero?
        [ drop ]
        [ f send: \exitFullScreenModeWithOptions: ] if
    ] [ window>> send: release ] bi ;

M: cocoa-ui-backend (grab-input)
    0 CGAssociateMouseAndMouseCursorPosition drop
    CGMainDisplayID CGDisplayHideCursor drop
    window>> send: frame CGRect>rect rect-center
    NSScreen send: screens 0 send: \objectAtIndex: send: frame CGRect-h
    [ drop first ] [ swap second - ] 2bi <CGPoint>
    [ GetCurrentButtonState zero? not ] [ yield ] while
    CGWarpMouseCursorPosition drop ;

M: cocoa-ui-backend (ungrab-input)
    drop
    CGMainDisplayID CGDisplayShowCursor drop
    1 CGAssociateMouseAndMouseCursorPosition drop ;

M: cocoa-ui-backend close-window
    find-world [
        handle>> [
            window>> send: close
        ] when*
    ] when* ;

M: cocoa-ui-backend raise-window*
    handle>> [
        window>> dup f send: \orderFront: send: makeKeyWindow
        NSApp 1 send: \activateIgnoringOtherApps:
    ] when* ;

M: window-handle select-gl-context ( handle -- )
    view>> send: openGLContext send: makeCurrentContext ;

M: window-handle flush-gl-context ( handle -- )
    view>> send: openGLContext send: flushBuffer ;

M: cocoa-ui-backend beep
    NSBeep ;

M: cocoa-ui-backend resize-window
    [ handle>> window>> ] [ first2 ] bi* <CGSize> send: \setContentSize: ;

M: cocoa-ui-backend system-alert
    NSAlert send: alloc send: init send: autorelease [
        {
            [ swap <NSString> send: \setInformativeText: ]
            [ swap <NSString> send: \setMessageText: ]
            [ "OK" <NSString> send: \addButtonWithTitle: drop ]
            [ send: runModal drop ]
        } cleave
    ] [ 2drop ] if* ;

<CLASS: FactorApplicationDelegate < NSObject

    COCOA-METHOD: void applicationDidUpdate: id obj [ reset-thread-timer ] ;

    COCOA-METHOD: char applicationShouldTerminateAfterLastWindowClosed: id app [
        ui-stop-after-last-window? get 1 0 ?
    ] ;
;CLASS>

: install-app-delegate ( -- )
    NSApp FactorApplicationDelegate install-delegate ;

INITIALIZED-SYMBOL: cocoa-startup-hook [
    [ "MiniFactor.nib" load-nib install-app-delegate ]
]

M: cocoa-ui-backend (with-ui)
    "UI" assert.app [
        init-clipboard
        cocoa-startup-hook get call( -- )
        start-ui
        stop-io-thread
        init-thread-timer
        reset-thread-timer
        NSApp send: run
        NSApp send: run
    ] with-cocoa ;

cocoa-ui-backend ui-backend set-global

M: cocoa-ui-backend ui-backend-available?
    running.app? ;
