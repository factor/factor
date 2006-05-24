! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: objc-FactorApplicationDelegate

DEFER: FactorApplicationDelegate

IN: cocoa
USING: gadgets-listener kernel objc objc-NSApplication
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

IN: gadgets
USING: errors freetype gadgets-cocoa objc-NSOpenGLContext
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
            install-app-delegate
            reset-views
            reset-callbacks
            init-ui
            default-main-menu
            listener-window
            finish-launching
            event-loop
        ] with-cocoa
    ] with-freetype ;

IN: kernel

: default-shell running.app? "ui" "tty" ? ;
