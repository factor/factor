USING: compiler io parser sequences words ;

{
    "/library/cocoa/objc-runtime.factor"
    "/library/cocoa/objc-utils.factor"
    "/library/cocoa/core-foundation.factor"
    "/library/cocoa/cocoa-types.factor"
    "/library/cocoa/init-cocoa.factor"
    "/library/cocoa/application-utils.factor"
    "/library/cocoa/window-utils.factor"
} [
    run-resource
] each

"Compiling Cocoa bindings..." print
vocabs [ "objc-" head? ] subset compile-vocabs
