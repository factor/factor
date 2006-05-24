! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: objc-FactorApplicationDelegate

DEFER: FactorApplicationDelegate

IN: cocoa
USING: gadgets gadgets-listener kernel objc objc-NSApplication
objc-NSObject ;

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

IN: gadgets
USING: errors freetype objc-NSOpenGLContext
objc-NSOpenGLView objc-NSView objc-NSWindow ;

: redraw-world ( handle -- )
    world-handle 1 [setNeedsDisplay:] ;

: open-window* ( world title -- )
    >r <FactorView> r> <ViewWindow> 
    dup install-window-delegate
    [contentView] [release] ;

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
            init-cocoa-ui
            listener-window
            finish-launching
            event-loop
        ] with-cocoa
    ] with-freetype ;

IN: kernel

: default-shell running.app? "ui" "tty" ? ;
