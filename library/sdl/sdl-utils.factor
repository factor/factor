! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: sdl
USE: alien
USE: math
USE: namespaces
USE: compiler
USE: words
USE: parser
USE: kernel
USE: errors
USE: lists
USE: prettyprint
USE: sdl-event
USE: sdl-gfx
USE: sdl-video

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
    [ >r init-screen r> call SDL_Quit ] with-scope ; inline

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
    inline

: with-pixels ( w h quot -- )
    -rot rect> [ over >r pixel-step r> ] 2times* drop ; inline

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
