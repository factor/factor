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

! This is a kind of high level wrapper around SDL, and turtle
! graphics, in one messy, undocumented package. Will be improved
! later, and heavily refactored, so don't count on this
! interface remaining unchanged.

SYMBOL: surface
SYMBOL: pixels
SYMBOL: format
SYMBOL: pen
SYMBOL: angle
SYMBOL: color

: xy-4 ( #{ x y } -- offset )
    >rect surface get surface-pitch * swap 4 * + ;

: set-pixel-4 ( color #{ x y } -- )
    xy-4 pixels get swap set-alien-4 ;

: rgb ( r g b -- value )
    >r >r >r format get r> r> r> SDL_MapRGB ;

: pixel-4-step ( quot #{ x y } -- )
    dup >r swap call rgb r> set-pixel-4 ;

: with-pixels-4 ( w h quot -- )
    -rot rect> [ over >r pixel-4-step r> ] 2times* drop ;

: move ( #{ x y } -- )
    pen +@ ;

: turn ( angle -- )
    angle +@ ;

: move-d ( distance -- )
    angle get cis * move ;

: pixel ( -- )
    color get pen get set-pixel-4 ;

: sgn ( x -- -1/0/1 ) dup 0 = [ 0 < -1 1 ? ] unless ;

: line-h-step ( #{ dx dy } #{ px py } p -- p )
    over real fixnum- dup 0 < [
        swap imaginary fixnum+ swap
    ] [
        nip swap real
    ] ifte move pixel ;

: line-more-h ( #{ dx dy } #{ px py } -- )
    dup imaginary 2 fixnum/i over imaginary [
        >r 2dup r> line-h-step
    ] times 3drop ;

: line-v-step ( #{ dx dy } #{ px py } p -- p )
    over imaginary fixnum- dup 0 fixnum< [
        swap real fixnum+ swap
    ] [
        nip swap imaginary 0 swap rect>
    ] ifte move pixel ;

: line-more-v ( #{ dx dy } #{ px py } -- )
    dup real 2 fixnum/i over real [
        >r 2dup r> line-v-step
    ] times 3drop ;

: line ( #{ x y } -- )
    pixel ( first point )
    dup >r >rect swap sgn swap sgn rect> r>
    >rect swap abs swap abs 2dup fixnum< [
        rect> line-more-h
    ] [
        rect> line-more-v
    ] ifte ;

: line-d ( distance -- )
    angle get cis * line ;

: with-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    surface get dup must-lock-surface? [
        dup SDL_LockSurface slip SDL_UnlockSurface
    ] [
        drop call
    ] ifte surface get SDL_Flip ;

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
