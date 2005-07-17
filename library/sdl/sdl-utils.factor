! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sdl
USING: kernel lists math namespaces ;

SYMBOL: surface
SYMBOL: width
SYMBOL: height
SYMBOL: bpp
SYMBOL: surface

: init-screen ( width height bpp flags -- )
    >r 3dup bpp set height set width set r>
    SDL_SetVideoMode surface set ;

: with-screen ( width height bpp flags quot -- )
    #! Set up SDL graphics and call the quotation.
    SDL_INIT_EVERYTHING SDL_Init drop
    1 SDL_EnableUNICODE drop
    SDL_DEFAULT_REPEAT_DELAY SDL_DEFAULT_REPEAT_INTERVAL
    SDL_EnableKeyRepeat drop
    [ >r init-screen r> call SDL_Quit ] with-scope ; inline

: rgb ( [ r g b ] -- n )
    3unlist
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
    <rect>
    [ set-rect-h ] keep
    [ set-rect-w ] keep
    [ set-rect-y ] keep
    [ set-rect-x ] keep ;

: with-pixels ( quot -- )
    width get [
        height get [
            [ rot dup slip swap surface get swap ] 2keep
            [ rot pixelColor ] 2keep
        ] repeat
    ] repeat drop ; inline

: with-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    [
        surface get dup must-lock-surface? [
            dup SDL_LockSurface drop slip dup SDL_UnlockSurface
        ] [
            slip
        ] ifte SDL_Flip drop
    ] with-scope ; inline
