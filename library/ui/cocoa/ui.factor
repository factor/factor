! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: objc-classes
DEFER: FactorApplicationDelegate

IN: cocoa
USING: arrays gadgets gadgets-listener gadgets-help
gadgets-workspace hashtables kernel memory namespaces objc
sequences errors freetype help ;

: finder-run-files ( alien -- )
    #! We filter out the image name since that might be there on
    #! first launch.
    CF>string-array [ image = not ] subset listener-run-files
    NSApp NSApplicationDelegateReplySuccess
    -> replyToOpenOrPrint: ;

: menu-run-files ( -- )
    open-panel [ listener-run-files ] when* ;

: menu-save-image ( -- )
    image save-panel [ save-image ] when* ;

! Handle Open events from the Finder
"NSObject" "FactorApplicationDelegate" {
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
    }
} define-objc-class

: install-app-delegate ( -- )
    NSApp FactorApplicationDelegate install-delegate ;

: load-nib ( -- )
    NSBundle
    "Factor.nib" <NSString> NSApp -> loadNibNamed:owner:
    drop ;

: init-cocoa ( -- )
    load-nib
    install-app-delegate
    register-services
    init-clipboard ;

: rect>NSRect
    dup world-loc first2 rot rect-dim first2 <NSRect> ;

: gadget-window ( world -- )
    [
        dup <FactorView>
        dup rot rect>NSRect <ViewWindow>
        dup install-window-delegate
        over -> release
        2array
    ] keep set-world-handle ;

IN: gadgets

: set-title ( string world -- )
    world-handle second swap <NSString> -> setTitle: ;

: open-window* ( world -- )
    dup gadget-window
    dup start-world
    world-handle second f -> makeKeyAndOrderFront: ;

: raise-window ( world -- )
    world-handle second dup f -> orderFront: -> makeKeyWindow
    NSApp 1 -> activateIgnoringOtherApps: ;

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
            init-timers
            init-cocoa
            restore-windows? [
                restore-windows
            ] [
                init-ui
                workspace-window
                drop
            ] if
            finish-launching
            event-loop
        ] with-cocoa
    ] with-freetype ;

IN: command-line

: default-shell running.app? "ui" "tty" ? ;
