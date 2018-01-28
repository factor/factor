! Copyright (C) 2006, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax cocoa cocoa.application cocoa.classes
cocoa.dialogs cocoa.nibs cocoa.pasteboard cocoa.runtime
cocoa.subclassing core-foundation.strings eval kernel listener
locals memory namespaces system ui.backend.cocoa
ui.theme.switching ui.tools.browser ui.tools.listener
vocabs.refresh ;
FROM: alien.c-types => int void ;
IN: ui.backend.cocoa.tools

: finder-run-files ( alien -- )
    CFString>string-array listener-run-files
    NSApp NSApplicationDelegateReplySuccess
    send: \replyToOpenOrPrint: ;

: menu-run-files ( -- )
    open-panel [ listener-run-files ] when* ;

: menu-save-image ( -- )
    image-path save-panel [ save-image ] when* ;

! Handle Open events from the Finder
<CLASS: FactorWorkspaceApplicationDelegate < FactorApplicationDelegate

    COCOA-METHOD: void application: id app openFiles: id files [ files finder-run-files ] ;

    COCOA-METHOD: int applicationShouldHandleReopen: id app hasVisibleWindows: int flag [ flag 0 = [ show-listener ] when 1 ] ;

    COCOA-METHOD: id showFactorListener: id app [ show-listener f ] ;

    COCOA-METHOD: id showFactorBrowser: id app [ show-browser f ] ;

    COCOA-METHOD: id newFactorListener: id app [ listener-window f ] ;

    COCOA-METHOD: id newFactorBrowser: id app [ browser-window f ] ;

    COCOA-METHOD: id runFactorFile: id app [ menu-run-files f ] ;

    COCOA-METHOD: id saveFactorImage: id app [ save f ] ;

    COCOA-METHOD: id saveFactorImageAs: id app [ menu-save-image f ] ;

    COCOA-METHOD: id switchLightTheme: id app [ light-mode f ] ;

    COCOA-METHOD: id switchDarkTheme: id app [ dark-mode f ] ;

    COCOA-METHOD: id refreshAll: id app [ [ refresh-all ] \ refresh-all call-listener f ] ;
;CLASS>

: install-workspace-delegate ( -- )
    NSApp FactorWorkspaceApplicationDelegate install-delegate ;

! Service support; evaluate Factor code from other apps
:: do-service ( pboard error quot -- )
    pboard error ?pasteboard-string
    dup [ quot call( string -- result/f ) ] when
    [ pboard set-pasteboard-string ] when* ;

<CLASS: FactorServiceProvider < NSObject

    COCOA-METHOD: void evalInListener: id pboard userData: id userData error: id error
    [ pboard error [ eval-listener f ] do-service ] ;

    COCOA-METHOD: void evalToString: id pboard userData: id userData error: id error
    [
        pboard error
        [ [ (eval>string) ] with-interactive-vocabs ] do-service
    ] ;
;CLASS>

: register-services ( -- )
    NSApp
    FactorServiceProvider send: alloc send: init
    send: \setServicesProvider: ;

FUNCTION: void NSUpdateDynamicServices ( )

[
    install-workspace-delegate
    "Factor.nib" load-nib
    register-services
] cocoa-startup-hook set-global
