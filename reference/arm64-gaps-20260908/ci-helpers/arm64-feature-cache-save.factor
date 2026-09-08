! Seed a process-specific capability, then verify it cannot survive image startup.
USING: cpu.arm.64.features kernel memory namespaces sequences system words ;
IN: arm64-feature-cache-test

: saved-feature-dispatch ( -- branch )
    "saved-image-only" arm64-feature? [ "optional" ] [ "fallback" ] if ;

\ detected-arm64-features "memoize" word-prop
[ t swap set-first ] [ { "saved-image-only" } swap set-second ] bi
saved-feature-dispatch "optional" =
[ "Seeded feature cache was not observed" throw ] unless
"arm64-feature-cache.image" save-image-and-exit
