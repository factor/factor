! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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
USE: streams
USE: strings
USE: sdl-ttf

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

: rgb ( r g b -- n )
    255
    swap 8 shift bitor
    swap 16 shift bitor
    swap 24 shift bitor ;

: make-color ( r g b -- color )
    #! Make an SDL_Color struct. This will go away soon in favor
    #! of pass-by-value support in the FFI.
    255 24 shift
    swap 16 shift bitor
    swap 8 shift bitor
    swap bitor ;

: black 0 0 0 ;
: white 255 255 255 ;
: red 255 0 0 ;
: green 0 255 0 ;
: blue 0 0 255 ;

: clear-surface ( color -- )
    >r surface get 0 0 width get height get r> boxColor ;

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

SYMBOL: fonts

: null? ( alien -- ? )
    dup [ alien-address 0 = ] when ;

: <font> ( name ptsize -- font )
    >r resource-path swap cat2 r> TTF_OpenFont ;

: font ( name ptsize -- font )
    fonts get [
        2dup cons get [
            2nip
        ] [
            2dup cons >r <font> dup r> set
        ] ifte*
    ] bind ;

: make-rect ( x y w h -- rect )
    <rect>
    [ set-rect-h ] keep
    [ set-rect-w ] keep
    [ set-rect-y ] keep
    [ set-rect-x ] keep ;

: surface-rect ( x y surface -- rect )
    dup surface-w swap surface-h make-rect ;

: draw-surface ( x y surface -- )
    [
        [ surface-rect ] keep swap surface get 0 0
    ] keep surface-rect swap rot SDL_UpperBlit drop ;

: draw-string ( x y font text fg bg -- width )
    pick str-length 0 = [
        2drop 2drop 2drop 0
    ] [
        TTF_RenderText_Shaded
        [ draw-surface ] keep
        [ surface-w ] keep
        SDL_FreeSurface
    ] ifte ;

: size-string ( font text -- w h )
    dup str-length 0 = [
        drop TTF_FontHeight 0 swap
    ] [
        <int-box> <int-box> [ TTF_SizeText drop ] 2keep
        swap int-box-i swap int-box-i
    ] ifte ;

global [ <namespace> fonts set ] bind
