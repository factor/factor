! Copyright (C) 2006, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax cocoa cocoa.nibs cocoa.application
cocoa.classes cocoa.dialogs cocoa.pasteboard cocoa.runtime
cocoa.subclassing core-foundation core-foundation.strings
help.topics kernel memory namespaces parser system ui
ui.tools.browser ui.tools.listener ui.backend.cocoa eval
locals listener vocabs.refresh ;
FROM: alien.c-types => int void ;
IN: ui.backend.cocoa.tools

: finder-run-files ( alien -- )
    CF>string-array listener-run-files
    NSApp NSApplicationDelegateReplySuccess
    -> replyToOpenOrPrint: ;

: menu-run-files ( -- )
    open-panel [ listener-run-files ] when* ;

: menu-save-image ( -- )
    image save-panel [ save-image ] when* ;

! Handle Open events from the Finder
CLASS: FactorWorkspaceApplicationDelegate < FactorApplicationDelegate
[
    METHOD: void application: id app openFiles: id files [ files finder-run-files ]

    METHOD: int applicationShouldHandleReopen: id app hasVisibleWindows: int flag [ flag 0 = [ show-listener ] when 1 ]

    METHOD: id factorListener: id app [ show-listener f ]

    METHOD: id factorBrowser: id app [ show-browser f ]

    METHOD: id newFactorListener: id app [ listener-window f ]

    METHOD: id newFactorBrowser: id app [ browser-window f ]

    METHOD: id runFactorFile: id app [ menu-run-files f ]

    METHOD: id saveFactorImage: id app [ save f ]

    METHOD: id saveFactorImageAs: id app [ menu-save-image f ]

    METHOD: id refreshAll: id app [ [ refresh-all ] \ refresh-all call-listener f ]
]

: install-app-delegate ( -- )
    NSApp FactorWorkspaceApplicationDelegate install-delegate ;

! Service support; evaluate Factor code from other apps
:: do-service ( pboard error quot -- )
    pboard error ?pasteboard-string
    dup [ quot call( string -- result/f ) ] when
    [ pboard set-pasteboard-string ] when* ;

CLASS: FactorServiceProvider < NSObject
[
    METHOD: void evalInListener: id pboard userData: id userData error: id error
    [ pboard error [ eval-listener f ] do-service ]

    METHOD: void evalToString: id pboard userData: id userData error: id error
    [
        pboard error
        [ [ (eval>string) ] with-interactive-vocabs ] do-service
    ]
]

: register-services ( -- )
    NSApp
    FactorServiceProvider -> alloc -> init
    -> setServicesProvider: ;

FUNCTION: void NSUpdateDynamicServices ( )

[
    install-app-delegate
    "Factor.nib" load-nib
    register-services
] cocoa-startup-hook set-global
