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

! A graphical console.
!
! To run this code, bootstrap Factor like so:
!
! ./f boot.image.le32
!     -libraries:sdl:name=libSDL.so
!     -libraries:sdl-gfx:name=libSDL_gfx.
!
! (But all on one line)
!
! Then, start Factor as usual (./f factor.image) and enter this
! at the listener:
!
! USE: console
! start-console

IN: console
USE: generic
USE: vectors
USE: sdl
USE: sdl-event
USE: sdl-gfx
USE: sdl-video
USE: namespaces
USE: math
USE: kernel
USE: strings
USE: alien
USE: sdl-keyboard
USE: streams
USE: prettyprint
USE: listener
USE: threads
USE: stdio
USE: errors
USE: line-editor
USE: hashtables

#! A namespace holding console state.
SYMBOL: console
#! A vector. New lines are pushed on the end.
SYMBOL: lines
#! An integer. Line at top of screen.
SYMBOL: first-line
#! Current X co-ordinate.
SYMBOL: x
#! Current Y co-ordinate.
SYMBOL: y
#! A string buffer.
SYMBOL: output-line
#! A line editor object.
SYMBOL: input-line

! Rendering
: background HEX: 0000dbff ;
: foreground HEX: 6d92ffff ;
: cursor     HEX: ffff24ff ;

#! The font size is hardcoded here.
: line-height 8 ;
: char-width 8 ;

: next-line ( -- )
    0 x set  line-height y [ + ] change ;

: draw-line ( str -- )
    [ surface get x get y get ] keep foreground stringColor
    str-length char-width * x [ + ] change ;

: clear-display ( -- )
    surface get 0 0 width get height get background boxColor ;

: visible-lines ( -- n )
    height get line-height /i ;

: available-lines ( -- )
    lines get vector-length first-line get - ;

: draw-lines ( -- )
    visible-lines available-lines min [
        first-line get +
        lines get vector-nth draw-line
        next-line
    ] times* ;

: blink-interval 500 ;

: draw-cursor ( x -- )
    surface get
    swap
    y get
    over 1 +
    y get line-height +
    cursor boxColor ;

: draw-current ( -- )
    output-line get sbuf>str draw-line ;

: caret-x ( -- x )
    x get input-line get [ caret get char-width * + ] bind ;

: draw-input ( -- )
    caret-x >r
    input-line get [ line-text get ] bind draw-line
    r> draw-cursor ;

: draw-console ( -- )
    [
        0 x set
        0 y set
        clear-display
        draw-lines
        draw-current
        draw-input
    ] with-surface ;

: empty-buffer ( sbuf -- str )
    dup sbuf>str 0 rot set-sbuf-length ;

: add-line ( text -- )
    lines get vector-push
    lines get vector-length 1 + first-line get - visible-lines -
    dup 0 >= [
        first-line [ + ] change
    ] [
        drop
    ] ifte ;

: console-write ( text -- )
    "\n" split1 [       
        swap output-line get sbuf-append
        output-line get empty-buffer add-line
    ] when*
    output-line get sbuf-append ;

! The console stream

! Restoring this continuation returns to the
! top-level console event loop.
SYMBOL: redraw-continuation

! Restoring this continuation with a string on the stack returns
! to the caller of freadln.
SYMBOL: input-continuation

TRAITS: console-stream

C: console-stream ( console console-continuation -- stream )
    [
        redraw-continuation set
        console set
    ] extend ;

M: console-stream fflush ( stream -- )
    fauto-flush ;

M: console-stream fauto-flush ( stream -- )
    [
        console get [ draw-console ] bind
    ] bind ;

M: console-stream freadln ( stream -- line )
    [
        [
            console get [ input-continuation set ] bind
            redraw-continuation get dup [
                call
            ] [
                drop f
            ] ifte
        ] callcc1
    ] bind ;

M: console-stream fwrite-attr ( string style stream -- )
    [
        drop
        console get [ console-write ] bind
    ] bind ;

M: console-stream fclose ( stream -- ) drop ;

! Event handling
SYMBOL: event

: valid-char? 1 255 between? ;

: return-key
     input-line get [
         commit-history
         line-text get
         line-clear
     ] bind
     dup console-write "\n" console-write
     input-continuation get call ;

GENERIC: handle-event ( event -- ? )

PREDICATE: alien key-down-event
    keyboard-event-type SDL_KEYDOWN = ;

SYMBOL: keymap

{{
        [ [ "RETURN" ] | [ return-key ] ]
        [ [ "BACKSPACE" ] | [ input-line get [ backspace ] bind ] ]
        [ [ "LEFT" ] | [ input-line get [ left ] bind ] ]
        [ [ "RIGHT" ] | [ input-line get [ right ] bind ] ]
        [ [ "UP" ] | [ input-line get [ history-prev ] bind ] ]
        [ [ "DOWN" ] | [ input-line get [ history-next ] bind ] ]
        [ [ "CTRL" "k" ] | [ input-line get [ line-clear ] bind ] ]
}} keymap set

M: key-down-event handle-event ( event -- ? )
    dup keyboard-event>binding keymap get hash [
        call draw-console
    ] [
        keyboard-event-unicode dup valid-char? [
            input-line get [ insert-char ] bind draw-console
        ] [
            drop
        ] ifte
    ] ?ifte t ;

PREDICATE: alien quit-event
    quit-event-type SDL_QUIT = ;

M: quit-event handle-event ( event -- ? )
    drop f ;

M: alien handle-event ( event -- ? )
    drop t ;

: check-event ( -- ? )
    #! Check if there is a pending event.
    #! Return if we should continue or stop.
    event get dup SDL_PollEvent [
        handle-event [ check-event ] [ f ] ifte
    ] [
        drop t
    ] ifte ;

: init-console ( -- )
    <event> event set
    0 first-line set
    80 <vector> lines set
    <line-editor> input-line set
    80 <sbuf> output-line set
    1 SDL_EnableUNICODE drop
    SDL_DEFAULT_REPEAT_DELAY SDL_DEFAULT_REPEAT_INTERVAL
    SDL_EnableKeyRepeat drop ;

: console-loop ( -- )
    check-event [ console-loop ] when ;

: console-quit ( -- )
    redraw-continuation off
    input-continuation get [ f swap call ] when*
    SDL_Quit ;

SYMBOL: escape-continuation

IN: shells

: sdl ( -- )
    <namespace> [
        800 600 32 SDL_HWSURFACE init-screen
        init-console
    ] extend console set

    [
        escape-continuation set

        [
            console get swap <console-stream>
            [ print-banner listener ] with-stream
            SDL_Quit
            ( return from start-console word )
            escape-continuation get call
        ] callcc0

        console get [
            draw-console
            console-loop
            console-quit
        ] bind
    ] callcc0 ;
