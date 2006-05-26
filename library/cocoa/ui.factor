! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: objc-FactorApplicationDelegate

DEFER: FactorApplicationDelegate

IN: cocoa
USING: arrays gadgets gadgets-listener kernel objc
objc-NSApplication objc-NSObject objc-NSWindow sequences ;

: finder-run-files ( alien -- )
    CF>string-array listener-run-files
    NSApp NSApplicationDelegateReplySuccess
    [replyToOpenOrPrint:] ;

! Handle Open events from the Finder
"NSObject" "FactorApplicationDelegate" {
    { "application:openFiles:" "void" { "id" "SEL" "id" "id" }
        [ >r 3drop r> finder-run-files ]
    }
} { } define-objc-class

: install-app-delegate ( -- )
    NSApp
    FactorApplicationDelegate [alloc] [init] [setDelegate:] ;

: init-cocoa-ui ( -- )
    reset-views
    reset-callbacks
    init-ui
    install-app-delegate
    register-services
    default-main-menu ;

: gadget-window ( world -- )
    [
        <FactorView>
        dup <ViewWindow>
        dup install-window-delegate
        dup [contentView] [release]
        2array
    ] keep set-world-handle ;

IN: gadgets
USING: errors freetype objc-NSOpenGLContext
objc-NSOpenGLView objc-NSView ;

: redraw-world ( world -- )
    world-handle first 1 [setNeedsDisplay:] ;

: set-title ( string world -- )
    world-handle second swap <NSString> [setTitle:] ;

: open-window* ( world -- )
    dup gadget-window dup add-notify
    dup gadget-title over set-title
    world-handle second f [makeKeyAndOrderFront:] ;

: select-gl-context ( handle -- )
    first [openGLContext] [makeCurrentContext] ;

: flush-gl-context ( handle -- )
    first [openGLContext] [flushBuffer] ;

IN: shells

: ui
    running.app? [
        "The Factor UI requires you to run the supplied Factor.app." throw
    ] unless
    [
        [
            init-cocoa-ui
            listener-window
            finish-launching
            event-loop
        ] with-cocoa
    ] with-freetype ;

IN: kernel

: default-shell running.app? "ui" "tty" ? ;
