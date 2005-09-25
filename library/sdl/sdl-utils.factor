! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sdl
USING: errors kernel lists math namespaces sequences ;

SYMBOL: surface
SYMBOL: width
SYMBOL: height
SYMBOL: bpp

: init-screen ( width height bpp flags -- )
    >r 3dup bpp set height set width set r>
    SDL_SetVideoMode surface set ;

: sdl-error ( 0/-1 -- )
    0 = [ SDL_GetError throw ] unless ;

: with-screen ( width height bpp flags quot -- )
    #! Set up SDL graphics and call the quotation.
    SDL_INIT_EVERYTHING SDL_Init sdl-error
    1 SDL_EnableUNICODE drop
    SDL_DEFAULT_REPEAT_DELAY SDL_DEFAULT_REPEAT_INTERVAL
    SDL_EnableKeyRepeat drop
    [ >r init-screen r> call SDL_Quit ] with-scope ; inline

: rgb ( [ r g b ] -- n )
    first3
    255
    swap >fixnum 8 shift bitor
    swap >fixnum 16 shift bitor
    swap >fixnum 24 shift bitor ;

: make-color ( r g b -- color )
    #! Make an SDL_Color struct. This will go away soon in favor
    #! of pass-by-value support in the FFI.
    255 24 shift
    swap 16 shift bitor
    swap 8 shift bitor
    swap bitor ;

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

: must-lock-surface? ( surface -- ? )
    #! This is a macro in SDL_video.h.
    dup surface-offset 0 = [
        surface-flags
        SDL_HWSURFACE SDL_ASYNCBLIT bitor SDL_RLEACCEL bitor
        bitand 0 = not
    ] [
        drop t
    ] if ;

: with-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    [
        surface get dup must-lock-surface? [
            dup SDL_LockSurface drop slip dup SDL_UnlockSurface
        ] [
            slip
        ] if SDL_Flip drop
    ] with-scope ; inline

: surface-rect ( x y surface -- rect )
    dup surface-w swap surface-h make-rect ;
