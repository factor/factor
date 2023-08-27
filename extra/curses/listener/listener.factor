! Copyright (C) 2010 Philipp Brüschweiler.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators continuations curses io io.encodings.string
io.encodings.utf8 io.streams.plain kernel listener make math
namespaces sequences ;
IN: curses.listener

: print-scratchpad ( -- )
    COLOR_BLACK COLOR_RED ccolor
    "( scratchpad )" cwrite
    COLOR_WHITE COLOR_BLACK ccolor
    " " cwritef ;

! don't handle mouse clicks right now
: handle-mouse-click ( -- )
    ;

: delchar ( y x -- )
    [ cmove CHAR: space addch ] [ cmove ] 2bi ;

: move-left ( -- )
    get-yx [
        [ 1 - get-max-x 1 - delchar ] unless-zero
    ] [ 1 - delchar ] if-zero ;

: handle-backspace ( -- )
    building get [ pop* move-left ] unless-empty ;

: curses-stream-readln ( -- )
    getch dup CHAR: \n = [ addch ] [
        {
            { KEY_MOUSE [ handle-mouse-click ] }
            { 127 [ handle-backspace ] }
            { 4 [ return ] }    ! ^D
            [ [ , ] [ addch ] bi ]
        } case
        curses-stream-readln
    ] if ;

SINGLETON: curses-listener-stream

INSTANCE: curses-listener-stream input-stream
INSTANCE: curses-listener-stream output-stream

M: curses-listener-stream stream-readln
    drop [ curses-stream-readln ] B{ } make utf8 decode ;

M: curses-listener-stream stream-write
    drop cwrite ;

M: curses-listener-stream stream-write1
    drop addch ;

M: curses-listener-stream stream-flush
    drop crefresh ;

M: curses-listener-stream stream-nl
    drop cnl ;

INSTANCE: curses-listener-stream plain-writer

: run-listener ( -- )
    <curses-window> [
        curses-listener-stream dup [ listener ] with-streams*
    ] with-curses ;

: test-listener ( -- )
    [ run-listener ] with-global ;

MAIN: run-listener
