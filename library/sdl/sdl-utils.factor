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

SYMBOL: surface
SYMBOL: width
SYMBOL: height

: rgba ( r g b a -- n )
    swap 8 shift bitor
    swap 16 shift bitor
    swap 24 shift bitor ;

: pixel-step ( quot #{ x y } -- )
    tuck >r call >r surface get r> r> >rect rot pixelColor ;

: with-pixels ( w h quot -- )
    -rot rect> [ over >r pixel-step r> ] 2times* drop ;

: (surface) ( -- surface )
    SDL_GetVideoSurface
    dup surface set
    dup surface-w width set
    dup surface-h height set ;

: with-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    [
        (surface) dup must-lock-surface? [
            dup SDL_LockSurface slip dup SDL_UnlockSurface
        ] [
            slip
        ] ifte SDL_Flip
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
