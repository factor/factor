! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar curses curses.ffi kernel random sequences threads
tools.test ;
IN: curses.tests

: hello-curses ( -- )
    <curses-window> [
        "Hello Curses!" [
            dup cmove addch
        ] each-index
        crefresh

        2 seconds sleep
    ] with-curses ;

: hello-curses-color ( -- )
    <curses-window> [
        "Hello Curses!" [
            8 random 8 random ccolor addch
        ] each crefresh

        2 seconds sleep
    ] with-curses ;

curses-ok? [
    { } [ hello-curses ] unit-test
    has_colors [
        { } [ hello-curses-color ] unit-test
    ] when
] when
