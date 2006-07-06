USING: kernel parser sequences ;

{
    { [ cpu "x86" = ] [ "/library/compiler/x86/objc.factor" ] }
    { [ cpu "ppc" = ] [ "/library/compiler/ppc/objc.factor" ] }
} cond run-resource

{
    "/library/compiler/alien/objc/runtime.factor"
    "/library/compiler/alien/objc/utilities.factor"
    "/library/compiler/alien/objc/subclassing.factor"
} [
    run-resource
] each
