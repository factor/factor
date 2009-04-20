! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax cocoa cocoa.nibs cocoa.application
cocoa.classes cocoa.dialogs cocoa.pasteboard cocoa.subclassing
core-foundation core-foundation.strings help.topics kernel
memory namespaces parser system ui ui.tools.browser
ui.tools.listener ui.backend.cocoa eval locals tools.vocabs ;
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
CLASS: {
    { +superclass+ "FactorApplicationDelegate" }
    { +name+ "FactorWorkspaceApplicationDelegate" }
}

{ "application:openFiles:" "void" { "id" "SEL" "id" "id" }
    [ [ 3drop ] dip finder-run-files ]
}

{ "applicationShouldHandleReopen:hasVisibleWindows:" "int" { "id" "SEL" "id" "int" }
    [ [ 3drop ] dip 0 = [ show-listener ] when 0 ]
}

{ "factorListener:" "id" { "id" "SEL" "id" }
    [ 3drop show-listener f ]
}

{ "factorBrowser:" "id" { "id" "SEL" "id" }
    [ 3drop show-browser f ]
}

{ "newFactorListener:" "id" { "id" "SEL" "id" }
    [ 3drop listener-window f ]
}

{ "newFactorBrowser:" "id" { "id" "SEL" "id" }
    [ 3drop browser-window f ]
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

{ "refreshAll:" "id" { "id" "SEL" "id" }
    [ 3drop [ refresh-all ] \ refresh-all call-listener f ]
} ;

: install-app-delegate ( -- )
    NSApp FactorWorkspaceApplicationDelegate install-delegate ;

! Service support; evaluate Factor code from other apps
:: do-service ( pboard error quot -- )
    pboard error ?pasteboard-string
    dup [ quot call( string -- result/f ) ] when
    [ pboard set-pasteboard-string ] when* ;

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "FactorServiceProvider" }
} {
    "evalInListener:userData:error:"
    "void"
    { "id" "SEL" "id" "id" "id" }
    [ nip [ eval-listener f ] do-service 2drop ]
} {
    "evalToString:userData:error:"
    "void"
    { "id" "SEL" "id" "id" "id" }
    [ nip [ eval>string ] do-service 2drop ]
} ;

: register-services ( -- )
    NSApp
    FactorServiceProvider -> alloc -> init
    -> setServicesProvider: ;

FUNCTION: void NSUpdateDynamicServices ;

[
    install-app-delegate
    "Factor.nib" load-nib
    register-services
] cocoa-init-hook set-global
