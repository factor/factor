IN: sdl
USE: alien
USE: math
USE: namespaces
USE: stack
USE: compiler
USE: words
USE: parser
USE: kernel
USE: errors
USE: combinators
USE: lists
USE: logic
USE: prettyprint

SYMBOL: surface
SYMBOL: width
SYMBOL: height
SYMBOL: bpp
SYMBOL: surface

: with-screen ( width height bpp flags quot -- )
    #! Set up SDL graphics and call the quotation.
    [
        >r
        >r 3dup bpp set height set width set r>
        SDL_SetVideoMode surface set
        r> call SDL_Quit
    ] with-scope ;

: rgba ( r g b a -- n )
    swap 8 shift bitor
    swap 16 shift bitor
    swap 24 shift bitor ;

: black 0 0 0 255 rgba ;
: white 255 255 255 255 rgba ;
: red 255 0 0 255 rgba ;
: green 0 255 0 255 rgba ;
: blue 0 0 255 255 rgba ;

: clear-surface ( color -- )
    >r surface get 0 0 width get height get r> boxColor ;

: pixel-step ( quot #{ x y } -- )
    tuck >r call >r surface get r> r> >rect rot pixelColor ;

: with-pixels ( w h quot -- )
    -rot rect> [ over >r pixel-step r> ] 2times* drop ;

: with-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    [
        surface get dup must-lock-surface? [
            dup SDL_LockSurface slip dup SDL_UnlockSurface
        ] [
            slip
        ] ifte SDL_Flip drop
    ] with-scope ;

: event-loop ( event -- )
    dup SDL_WaitEvent 1 = [
        dup event-type SDL_QUIT = [
            drop
        ] [
            event-loop
        ] ifte
    ] [
        drop
    ] ifte ;
