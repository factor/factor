! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators continuations kernel locals system vocabs vocabs.loader ;
IN: raylib.live-coding.contexts

HOOK: current-context os ( -- context )
HOOK: make-context-current os ( context -- )

:: with-context-restored ( context quot -- )
    [ f make-context-current quot call ]
    [ context make-context-current ] finally ; inline

: with-saved-context ( quot -- )
    current-context swap with-context-restored ; inline

{
    { [ os macos? ] [ "raylib.live-coding.contexts.cocoa" ] }
    { [ os windows? ] [ "raylib.live-coding.contexts.windows" ] }
    { [ os unix? ] [ "raylib.live-coding.contexts.unix" ] }
} cond require
