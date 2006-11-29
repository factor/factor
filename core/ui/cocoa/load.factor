USING: compiler io parser sequences words ;

REQUIRES: core/compiler/alien/objc ;

PROVIDE: core/ui/cocoa
{ +files+ { 
    "core-foundation.factor"
    "types.factor"
    "init-cocoa.factor"
    "application-utils.factor"
    "pasteboard-utils.factor"
    "view-utils.factor"
    "window-utils.factor"
    "dialogs.factor"
    "services.factor"
    "ui.factor"
} }
{ +tests+ {
    "test/cocoa.factor"
} } ;

"Compiling Cocoa bindings..." print
{ "cocoa" "objc" "objc-classes" "gadgets" } compile-vocabs
