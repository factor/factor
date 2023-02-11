! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax cocoa cocoa.application cocoa.classes
cocoa.dialogs cocoa.nibs cocoa.pasteboard cocoa.runtime
cocoa.subclassing core-foundation.strings eval kernel listener
locals memory namespaces parser system ui.backend.cocoa
ui.theme.switching ui.tools.browser ui.tools.listener
vocabs.refresh ;
FROM: alien.c-types => int void ;
IN: ui.backend.cocoa.tools

: finder-run-files ( alien -- )
    CF>string-array listener-run-files
    NSApp NSApplicationDelegateReplySuccess
    -> replyToOpenOrPrint: ;

: menu-run-files ( -- )
    open-panel [ listener-run-files ] when* ;

: menu-save-image ( -- )
    image-path save-panel [ save-image ] when* ;

! Handle Open events from the Finder
<CLASS: FactorWorkspaceApplicationDelegate < FactorApplicationDelegate

    METHOD: void application: id app openFiles: id files [ files finder-run-files ] ;

    METHOD: int applicationShouldHandleReopen: id app hasVisibleWindows: int flag [ flag 0 = [ show-listener ] when 1 ] ;

    METHOD: id showFactorListener: id app [ show-listener f ] ;

    METHOD: id showFactorBrowser: id app [ show-browser f ] ;

    METHOD: id newFactorListener: id app [ listener-window f ] ;

    METHOD: id newFactorBrowser: id app [ browser-window f ] ;

    METHOD: id runFactorFile: id app [ menu-run-files f ] ;

    METHOD: id saveFactorImage: id app [ save f ] ;

    METHOD: id saveFactorImageAs: id app [ menu-save-image f ] ;

    METHOD: id switchLightTheme: id app [ light-mode f ] ;

    METHOD: id switchDarkTheme: id app [ dark-mode f ] ;

    METHOD: id switchWombatTheme: id app [ wombat-mode f ] ;

    METHOD: id switchBase16Theme: id app [ base16-mode f ] ;

    METHOD: id refreshAll: id app [ [ refresh-all ] \ refresh-all call-listener f ] ;
;CLASS>

: install-workspace-delegate ( -- )
    NSApp FactorWorkspaceApplicationDelegate install-delegate ;

! Service support; evaluate Factor code from other apps
:: do-service ( pboard error quot -- )
    pboard error ?pasteboard-string
    dup [ quot call( string -- result/f ) ] when
    [ pboard set-pasteboard-string ] when* ;

<CLASS: FactorServiceProvider < NSObject

    METHOD: void evalInListener: id pboard userData: id userData error: id error
    [ pboard error [ eval-listener f ] do-service ] ;

    METHOD: void evalToString: id pboard userData: id userData error: id error
    [
        pboard error [
            t auto-use? [
                [ (eval-with-stack>string) ] with-interactive-vocabs
            ] with-variable
        ] do-service
    ] ;
;CLASS>

: register-services ( -- )
    NSApp
    FactorServiceProvider -> alloc -> init
    -> setServicesProvider: ;

FUNCTION: void NSUpdateDynamicServices ( )

[
    install-workspace-delegate
    "Factor.nib" load-nib
    register-services
] cocoa-startup-hook set-global
