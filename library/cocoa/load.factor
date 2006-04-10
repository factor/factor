USING: compiler io parser sequences words ;

{
    "/library/cocoa/runtime.factor"
    "/library/cocoa/utilities.factor"
    "/library/cocoa/subclassing.factor"
    "/library/cocoa/core-foundation.factor"
    "/library/cocoa/types.factor"
    "/library/cocoa/init-cocoa.factor"
    "/library/cocoa/callback.factor"
    "/library/cocoa/application-utils.factor"
    "/library/cocoa/window-utils.factor"
    "/library/cocoa/view-utils.factor"
    "/library/cocoa/menu-bar.factor"
    "/library/cocoa/ui.factor"
} [
    run-resource
] each

"Compiling Cocoa bindings..." print
vocabs [ "objc-" head? ] subset compile-vocabs
