USING: compiler io parser sequences words ;

{
    "/library/ui/cocoa/core-foundation.factor"
    "/library/ui/cocoa/types.factor"
    "/library/ui/cocoa/init-cocoa.factor"
    "/library/ui/cocoa/callback.factor"
    "/library/ui/cocoa/application-utils.factor"
    "/library/ui/cocoa/pasteboard-utils.factor"
    "/library/ui/cocoa/view-utils.factor"
    "/library/ui/cocoa/window-utils.factor"
    "/library/ui/cocoa/dialogs.factor"
    "/library/ui/cocoa/menu-bar.factor"
    "/library/ui/cocoa/services.factor"
    "/library/ui/cocoa/ui.factor"
} [
    run-resource
] each

"Compiling Cocoa bindings..." print
{ "cocoa" "objc" "objc-classes" "gadgets" } compile-vocabs
