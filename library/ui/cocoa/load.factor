USING: compiler io parser sequences words ;

REQUIRES: library/compiler/alien/objc ;

PROVIDE: library/ui/cocoa {
    "core-foundation.factor"
    "types.factor"
    "init-cocoa.factor"
    "callback.factor"
    "application-utils.factor"
    "pasteboard-utils.factor"
    "view-utils.factor"
    "window-utils.factor"
    "dialogs.factor"
    "menu-bar.factor"
    "services.factor"
    "ui.factor"
} ;

"Compiling Cocoa bindings..." print
{ "cocoa" "objc" "objc-classes" "gadgets" } compile-vocabs
