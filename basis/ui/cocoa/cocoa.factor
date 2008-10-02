! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors math arrays cocoa cocoa.application
command-line kernel memory namespaces cocoa.messages
cocoa.runtime cocoa.subclassing cocoa.pasteboard cocoa.types
cocoa.windows cocoa.classes cocoa.application sequences system
ui ui.backend ui.clipboards ui.gadgets ui.gadgets.worlds
ui.cocoa.views core-foundation threads math.geometry.rect ;
IN: ui.cocoa

TUPLE: handle view window ;

C: <handle> handle

SINGLETON: cocoa-ui-backend

M: cocoa-ui-backend do-events ( -- )
    [
        [ NSApp [ do-event ] curry loop ui-wait ] ui-try
    ] with-autorelease-pool ;

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
    dup window-loc>> first2 rot rect-dim first2 <NSRect> ;

: gadget-window ( world -- )
    [
        dup <FactorView>
        dup rot world>NSRect <ViewWindow>
        dup install-window-delegate
        over -> release
        <handle>
    ] keep (>>handle) ;

M: cocoa-ui-backend set-title ( string world -- )
    handle>> window>> swap <NSString> -> setTitle: ;

: enter-fullscreen ( world -- )
    handle>> view>>
    NSScreen -> mainScreen
    f -> enterFullScreenMode:withOptions:
    drop ;

: exit-fullscreen ( world -- )
    handle>> view>> f -> exitFullScreenModeWithOptions: ;

M: cocoa-ui-backend set-fullscreen* ( ? world -- )
    swap [ enter-fullscreen ] [ exit-fullscreen ] if ;

M: cocoa-ui-backend fullscreen* ( world -- ? )
    handle>> view>> -> isInFullScreenMode zero? not ;

: auto-position ( world -- )
    dup window-loc>> { 0 0 } = [
        handle>> window>> -> center
    ] [
        drop
    ] if ;

M: cocoa-ui-backend (open-window) ( world -- )
    dup gadget-window
    dup auto-position
    handle>> window>> f -> makeKeyAndOrderFront: ;

M: cocoa-ui-backend (close-window) ( handle -- )
    window>> -> release ;

M: cocoa-ui-backend close-window ( gadget -- )
    find-world [
        handle>> [
            window>> f -> performClose:
        ] when*
    ] when* ;

M: cocoa-ui-backend raise-window* ( world -- )
    handle>> [
        window>> dup f -> orderFront: -> makeKeyWindow
        NSApp 1 -> activateIgnoringOtherApps:
    ] when* ;

M: cocoa-ui-backend select-gl-context ( handle -- )
    view>> -> openGLContext -> makeCurrentContext ;

M: cocoa-ui-backend flush-gl-context ( handle -- )
    view>> -> openGLContext -> flushBuffer ;

M: cocoa-ui-backend beep ( -- )
    NSBeep ;

SYMBOL: cocoa-init-hook

M: cocoa-ui-backend ui
    "UI" assert.app [
        [
            init-clipboard
            cocoa-init-hook get [ call ] when*
            start-ui
            finish-launching
            event-loop
        ] ui-running
    ] with-cocoa ;

cocoa-ui-backend ui-backend set-global

[ running.app? "ui" "listener" ? ] main-vocab-hook set-global
