USING: cpu.arm.64.features cpu.arm.64.features.windows kernel
memory namespaces sequences system tools.test words ;
IN: windows-feature-persistence-test

! This ordinary compiled caller must consult the process cache at runtime.
: saved-dispatch ( -- branch )
    "saved-image-only" arm64-feature? [ "optional" ] [ "fallback" ] if ;

\ detected-arm64-features "memoize" word-prop
[ t swap set-first ] [ { "saved-image-only" } swap set-second ] bi
{ "optional" } [ saved-dispatch ] unit-test
"reference/arm64-gap-windows-features-20260908/dispatch.image" save-image-and-exit
