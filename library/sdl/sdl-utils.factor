! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sdl
USING: alien arrays errors hashtables io kernel lists math
namespaces sequences styles ;

SYMBOL: surface
SYMBOL: width
SYMBOL: height
SYMBOL: bpp

: sdl-error ( 0/-1 -- )
    0 = [ SDL_GetError throw ] unless ;

: ttf-name ( font style -- name )
    cons {{
        [[ [[ "Monospaced" plain       ]] "VeraMono" ]]
        [[ [[ "Monospaced" bold        ]] "VeraMoBd" ]]
        [[ [[ "Monospaced" bold-italic ]] "VeraMoBI" ]]
        [[ [[ "Monospaced" italic      ]] "VeraMoIt" ]]
        [[ [[ "Sans Serif" plain       ]] "Vera"     ]]
        [[ [[ "Sans Serif" bold        ]] "VeraBd"   ]]
        [[ [[ "Sans Serif" bold-italic ]] "VeraBI"   ]]
        [[ [[ "Sans Serif" italic      ]] "VeraIt"   ]]
        [[ [[ "Serif" plain            ]] "VeraSe"   ]]
        [[ [[ "Serif" bold             ]] "VeraSeBd" ]]
        [[ [[ "Serif" bold-italic      ]] "VeraBI"   ]]
        [[ [[ "Serif" italic           ]] "VeraIt"   ]]
    }} hash ;

: ttf-path ( name -- string )
    [ "/fonts/" % % ".ttf" % ] "" make resource-path ;

: open-font ( { font style ptsize } -- alien )
    first3 >r ttf-name ttf-path r> TTF_OpenFont
    dup alien-address 0 = [ SDL_GetError throw ] when ;

SYMBOL: open-fonts

: lookup-font ( font style ptsize -- font )
    3array open-fonts get [ open-font ] cache ;

: init-ttf ( -- )
    TTF_Init sdl-error
    global [
        open-fonts [ [ cdr expired? not ] hash-subset ] change
    ] bind ;

: init-keyboard ( -- )
    1 SDL_EnableUNICODE drop
    SDL_DEFAULT_REPEAT_DELAY SDL_DEFAULT_REPEAT_INTERVAL
    SDL_EnableKeyRepeat drop ;

: init-surface ( width height bpp flags -- )
    >r 3dup bpp set height set width set r>
    SDL_SetVideoMode surface set ;

: init-sdl ( width height bpp flags -- )
    SDL_INIT_EVERYTHING SDL_Init sdl-error
    init-keyboard init-surface init-ttf ;

: with-screen ( width height bpp flags quot -- )
    #! Set up SDL graphics and call the quotation.
    [ [ >r init-sdl r> call ] [ SDL_Quit ] cleanup ] with-scope ;
    inline

: rgb ( [ r g b ] -- n )
    first3
    255
    swap >fixnum 8 shift bitor
    swap >fixnum 16 shift bitor
    swap >fixnum 24 shift bitor ;

: make-color ( r g b -- color )
    #! Make an SDL_Color struct. This will go away soon in favor
    #! of pass-by-value support in the FFI.
    <sdl-color>
    [ set-sdl-color-b ] keep
    [ set-sdl-color-g ] keep
    [ set-sdl-color-r ] keep
    0 alien-unsigned-4 ;

: make-rect ( x y w h -- rect )
    <sdl-rect>
    [ set-sdl-rect-h ] keep
    [ set-sdl-rect-w ] keep
    [ set-sdl-rect-y ] keep
    [ set-sdl-rect-x ] keep ;

: with-pixels ( quot -- )
    width get [
        height get [
            [ rot dup slip swap surface get swap ] 2keep
            [ rot pixelColor ] 2keep
        ] repeat
    ] repeat drop ; inline

: must-lock-surface? ( -- ? )
    #! This is a macro in SDL_video.h.
    surface get dup surface-offset 0 = [
        surface-flags
        SDL_HWSURFACE SDL_ASYNCBLIT bitor SDL_RLEACCEL bitor
        bitand 0 = not
    ] [
        drop t
    ] if ;

: lock-surface ( -- )
    surface get SDL_LockSurface drop ;

: unlock-surface ( -- )
    surface get SDL_UnlockSurface ;

: with-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    [
        must-lock-surface? [ lock-surface ] when
        call
    ] [
        must-lock-surface? [ unlock-surface ] when
        surface get SDL_Flip
    ] cleanup ; inline

: with-unlocked-surface ( quot -- )
    must-lock-surface?
    [ unlock-surface call lock-surface ] [ call ] if ; inline

: surface-rect ( x y surface -- rect )
    dup surface-w swap surface-h make-rect ;

{{ }} clone open-fonts global set-hash
