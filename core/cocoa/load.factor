USING: compiler io parser sequences words ;

PROVIDE: core/cocoa
{ +files+ {
    "runtime.factor"
    "message-send.factor"
    "subclassing.factor"
    "core-foundation.factor"
    "types.factor"
    "init-cocoa.factor"
    "application-utils.factor"
    "pasteboard-utils.factor"
    "view-utils.factor"
    "window-utils.factor"
    "dialogs.factor"
    "application-utils.facts"
    "core-foundation.facts"
    "dialogs.facts"
    "handbook.facts"
    "message-send.facts"
    "pasteboard-utils.facts"
    "subclassing.facts"
    "types.facts"
    "view-utils.facts"
    "window-utils.facts"
} }
{ +tests+ {
    "test/cocoa.factor"
} }
{ +help+ "cocoa" } ;

"Compiling Cocoa binding..." print
{ "cocoa" "objc" "objc-classes" } compile-vocabs
