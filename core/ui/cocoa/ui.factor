! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa-ui
USING: arrays cocoa gadgets gadgets-listener gadgets-help
gadgets-workspace hashtables kernel memory namespaces objc
objc-classes sequences errors freetype help timers ;

: finder-run-files ( alien -- )
    CF>string-array listener-run-files
    NSApp NSApplicationDelegateReplySuccess
    -> replyToOpenOrPrint: ;

: menu-run-files ( -- )
    open-panel [ listener-run-files ] when* ;

: menu-save-image ( -- )
    image save-panel [ save-image ] when* ;

! Handle Open events from the Finder
CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "FactorApplicationDelegate" }
}

{ "application:openFiles:" "void" { "id" "SEL" "id" "id" }
    [ >r 3drop r> finder-run-files ]
}

{ "newFactorWorkspace:" "id" { "id" "SEL" "id" }
    [ 3drop workspace-window f ]
}

{ "runFactorFile:" "id" { "id" "SEL" "id" }
    [ 3drop menu-run-files f ]
}

{ "saveFactorImage:" "id" { "id" "SEL" "id" }
    [ 3drop save f ]
}

{ "saveFactorImageAs:" "id" { "id" "SEL" "id" }
    [ 3drop menu-save-image f ]
}

{ "showFactorHelp:" "id" { "id" "SEL" "id" }
    [ 3drop "handbook" <link> help-gadget call-tool f ]
} ;

: install-app-delegate ( -- )
    NSApp FactorApplicationDelegate install-delegate ;

: event-loop ( -- )
    [ [ NSApp do-events ui-step ] ui-try ] with-autorelease-pool
    event-loop ;

TUPLE: pasteboard handle ;

M: pasteboard clipboard-contents
    pasteboard-handle pasteboard-string ;

M: pasteboard set-clipboard-contents
    pasteboard-handle set-pasteboard-string ;

: init-clipboard ( -- )
    NSPasteboard -> generalPasteboard <pasteboard>
    clipboard set-global ;

: init-cocoa ( -- )
    "Factor.nib" load-nib
    install-app-delegate
    register-services
    init-clipboard ;

: world>NSRect ( world -- NSRect )
    dup world-loc first2 rot rect-dim first2 <NSRect> ;

: gadget-window ( world -- )
    [
        dup <FactorView>
        dup rot world>NSRect <ViewWindow>
        dup install-window-delegate
        over -> release
        2array
    ] keep set-world-handle ;

IN: gadgets

: set-title ( string world -- )
    world-handle second swap <NSString> -> setTitle: ;

: auto-position ( world -- )
    dup world-loc { 0 0 } = [
        world-handle second -> center
    ] [
        drop
    ] if ;

: open-window* ( world -- )
    dup gadget-window
    dup start-world
    dup auto-position
    world-handle second f -> makeKeyAndOrderFront: ;

: raise-window ( world -- )
    world-handle [
        second dup f -> orderFront: -> makeKeyWindow
        NSApp 1 -> activateIgnoringOtherApps:
    ] when* ;

: select-gl-context ( handle -- )
    first -> openGLContext -> makeCurrentContext ;

: flush-gl-context ( handle -- )
    first -> openGLContext -> flushBuffer ;

: running.app? ( -- ? )
    #! Test if we're running Factor.app.
    "Factor.app"
    NSBundle -> mainBundle -> bundlePath CF>string
    subseq? ;

IN: shells

: ui
    running.app? [
        "The Factor UI requires you to run the supplied Factor.app." throw
    ] unless
    [
        [
            init-cocoa
            start-ui
            finish-launching
            event-loop
        ] with-cocoa
    ] with-freetype ;

IN: command-line

: default-shell running.app? "ui" "tty" ? ;
