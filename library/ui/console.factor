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
! USE: shells
! sdl

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
USE: lists
USE: sdl-ttf

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
#! A TTF_Font* value.
SYMBOL: console-font
#! Font height.
SYMBOL: line-height
#! If this is on, the console will be redrawn on the next event
#! refresh cycle.
SYMBOL: redraw-console

#! The font size is hardcoded here.
: char-width 8 ;

! Scrolling
: visible-lines ( -- n ) height get line-height get /i ;
: total-lines ( -- n ) lines get vector-length ;
: available-lines ( -- ) total-lines first-line get - ;

: fix-first-line ( line -- line )
    total-lines visible-lines - 1 + min 0 max ;

: change-first-line ( quot -- )
    first-line get
    swap call fix-first-line
    first-line set ; inline

: line-scroll-up   ( -- ) [ 1 - ] change-first-line ;
: line-scroll-down ( -- ) [ 1 + ] change-first-line ;
: page-scroll-up   ( -- ) [ visible-lines - ] change-first-line ;
: page-scroll-down ( -- ) [ visible-lines + ] change-first-line ;

: scroll-to-bottom ( -- )
    total-lines fix-first-line first-line set ;

! Rendering
: background white ;
: foreground black ;
: cursor     red   ;

: next-line ( -- )
    0 x set  line-height get y [ + ] change ;

: draw-line ( str -- )
    >r x get y get console-font get r>
    foreground make-color background make-color draw-string
    x [ + ] change ;

: clear-display ( -- )
    surface get 0 0 width get height get background rgb boxColor ;

: draw-lines ( -- )
    visible-lines available-lines min [
        dup first-line get +
        lines get vector-nth draw-line
        next-line
    ] repeat ;

: blink-interval 500 ;

: draw-cursor ( x -- )
    surface get
    swap
    y get
    over 1 +
    y get line-height get +
    cursor rgb boxColor ;

: draw-current ( -- )
    output-line get sbuf>str draw-line ;

: caret-x ( -- x )
    x get input-line get [
        console-font get caret get line-text get str-head
        size-string drop +
    ] bind ;

: draw-input ( -- )
    caret-x >r
    input-line get [ line-text get ] bind draw-line
    r> draw-cursor ;

: scrollbar-width 16 ;
: scroll-y ( line -- y ) total-lines 1 + / height get * ;
: scrollbar-top ( -- y ) first-line get scroll-y ;
: scrollbar-bottom ( -- y ) first-line get visible-lines + scroll-y ;

: draw-scrollbar ( -- )
    surface get
    width get scrollbar-width -
    scrollbar-top
    width get
    scrollbar-bottom
    black rgb boxColor ;

: draw-console ( -- )
    [
        0 x set
        0 y set
        clear-display
        draw-lines
        height get y get - line-height get >= [
            draw-current
            draw-input
        ] when
        draw-scrollbar
    ] with-surface ;

: empty-buffer ( sbuf -- str )
    dup sbuf>str 0 rot set-sbuf-length ;

: add-line ( text -- )
    lines get vector-push scroll-to-bottom ;

: console-write ( text -- )
    "\n" split1 [
        swap output-line get sbuf-append
        output-line get empty-buffer add-line
    ] when*
    output-line get sbuf-append ;

! The console stream

! Restoring this continuation with a string on the stack returns
! to the caller of freadln.
SYMBOL: input-continuation

TUPLE: console-stream console redraw-continuation ;

C: console-stream ( console console-continuation -- stream )
    [ set-console-stream-redraw-continuation ] keep
    [ set-console-stream-console ] keep ;

M: console-stream fflush ( stream -- )
    fauto-flush ;

M: console-stream fauto-flush ( stream -- )
    console-stream-console [ redraw-console on ] bind ;

M: console-stream freadln ( stream -- line )
    [
        swap [
            console-stream-console
            [ input-continuation set ] bind
        ] keep
        dup console-stream-redraw-continuation dup [
            call
        ] [
            drop f
        ] ifte
    ] callcc1 nip ;

M: console-stream fwrite-attr ( string style stream -- )
    nip console-stream-console [ console-write ] bind ;

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

SYMBOL: keymap

{{
    [[ [ "RETURN" ] [ return-key ] ]]
    [[ [ "BACKSPACE" ] [ input-line get [ backspace ] bind ] ]]
    [[ [ "LEFT" ] [ input-line get [ left ] bind ] ]]
    [[ [ "RIGHT" ] [ input-line get [ right ] bind ] ]]
    [[ [ "UP" ] [ input-line get [ history-prev ] bind ] ]]
    [[ [ "SHIFT" "DOWN" ] [ line-scroll-down ] ]]
    [[ [ "SHIFT" "UP" ] [ line-scroll-up ] ]]
    [[ [ "PAGEDOWN" ] [ page-scroll-down ] ]]
    [[ [ "PAGEUP" ] [ page-scroll-up ] ]]
    [[ [ "DOWN" ] [ input-line get [ history-next ] bind ] ]]
    [[ [ "CTRL" "k" ] [ input-line get [ line-clear ] bind ] ]]
}} keymap set

: input-key? ( event -- ? )
    #! Is this a keystroke that potentially inserts input, or
    #! does it have modifiers?
    keyboard-event-unicode valid-char? ;

: user-input ( char -- )
    input-line get [ insert-char ] bind  scroll-to-bottom ;

M: key-down-event handle-event ( event -- ? )
    dup keyboard-event>binding keymap get hash [
        call redraw-console on
    ] [
        dup input-key? [
            keyboard-event-unicode user-input redraw-console on
        ] [
            drop
        ] ifte
    ] ?ifte t ;

! The y co-ordinate of the start of the drag.
SYMBOL: drag-start-y
! The first line at the time
SYMBOL: drag-start-line

: scrollbar-click ( y -- )
    dup scrollbar-top < [
        drop page-scroll-up redraw-console on
    ] [
        dup scrollbar-bottom > [
            drop page-scroll-down redraw-console on
        ] [
            drag-start-y set
            first-line get drag-start-line set
        ] ifte
    ] ifte ;

M: button-down-event handle-event ( event -- ? )
    dup button-event-x width get scrollbar-width - >= [
        button-event-y scrollbar-click
    ] [
        drop
    ] ifte t ;

M: button-up-event handle-event ( event -- ? )
    drop
    drag-start-y off
    drag-start-line off t ;

M: motion-event handle-event ( event -- ? )
    drag-start-y get [
        motion-event-y drag-start-y get -
        height get / total-lines * drag-start-line get +
        >fixnum fix-first-line first-line set
        redraw-console on
    ] [
        drop
    ] ifte t ;

M: resize-event handle-event ( event -- ? )
    dup resize-event-w swap resize-event-h
    0 SDL_HWSURFACE SDL_RESIZABLE bitor init-screen
    scroll-to-bottom
    redraw-console on t ;

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

: set-console-font ( font ptsize )
    font dup console-font set
    TTF_FontHeight line-height set ;

: init-console ( -- )
    TTF_Init
    "/fonts/VeraMono.ttf" 14 set-console-font
    <event> event set
    0 first-line set
    80 <vector> lines set
    <line-editor> input-line set
    80 <sbuf> output-line set
    1 SDL_EnableUNICODE drop
    SDL_DEFAULT_REPEAT_DELAY SDL_DEFAULT_REPEAT_INTERVAL
    SDL_EnableKeyRepeat drop ;

: console-loop ( -- )
    redraw-console get [ draw-console redraw-console off ] when
    check-event [ console-loop ] when ;

: console-quit ( -- )
    input-continuation get [ f swap call ] when*
    SDL_Quit ;

SYMBOL: escape-continuation

IN: shells

: sdl ( -- )
    <namespace> [
        640 480 0 SDL_HWSURFACE SDL_RESIZABLE bitor init-screen
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
            redraw-console on
            console-loop
            console-quit
        ] bind
    ] callcc0 ;
