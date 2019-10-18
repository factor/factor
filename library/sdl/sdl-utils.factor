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

: init-keyboard ( -- )
    1 SDL_EnableUNICODE drop
    SDL_DEFAULT_REPEAT_DELAY SDL_DEFAULT_REPEAT_INTERVAL
    SDL_EnableKeyRepeat drop ;

: init-surface ( width height bpp flags -- )
    >r 3dup bpp set height set width set r>
    SDL_SetVideoMode surface set ;

: init-sdl ( width height bpp flags -- )
    SDL_INIT_EVERYTHING SDL_Init sdl-error
    init-keyboard init-surface ;

: with-screen ( width height bpp flags quot -- )
    #! Set up SDL graphics and call the quotation.
    [ [ >r init-sdl r> call ] [ SDL_Quit ] cleanup ] with-scope ;
    inline

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
    must-lock-surface? [ surface get SDL_LockSurface drop ] when ;

: unlock-surface ( -- )
    must-lock-surface? [ surface get SDL_UnlockSurface ] when ;

: with-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    [ lock-surface call ]
    [ unlock-surface surface get SDL_Flip ]
    cleanup ; inline
