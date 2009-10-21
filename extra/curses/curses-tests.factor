! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar curses kernel threads tools.test
strings sequences ;
IN: curses.tests

: hello-curses ( -- )
    <curses-window> [
        "Hello Curses!" [
            dup cmove addch
        ] each-index
        crefresh

        2 seconds sleep
    ] with-curses ;

curses-ok? [
    [ ] [ hello-curses ] unit-test
] when
