! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax cocoa cocoa.nibs cocoa.application
cocoa.classes cocoa.dialogs cocoa.pasteboard cocoa.subclassing
core-foundation help.topics kernel memory namespaces parser
system ui ui.tools.browser ui.tools.listener ui.tools.workspace
ui.cocoa ;
IN: ui.cocoa.tools

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
    [ 3drop "handbook" com-follow f ]
} ;

: install-app-delegate ( -- )
    NSApp FactorApplicationDelegate install-delegate ;

! Service support; evaluate Factor code from other apps
: do-service ( pboard error quot -- )
    pick >r >r
    ?pasteboard-string dup [ r> call ] [ r> 2drop f ] if
    dup [ r> set-pasteboard-string ] [ r> 2drop ] if ;

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "FactorServiceProvider" }
} {
    "evalInListener:userData:error:"
    "void"
    { "id" "SEL" "id" "id" "void*" }
    [ nip [ eval-listener f ] do-service 2drop ]
} {
    "evalToString:userData:error:"
    "void"
    { "id" "SEL" "id" "id" "void*" }
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
