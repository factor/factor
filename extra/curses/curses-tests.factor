! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors curses kernel threads tools.test ;
IN: curses.tests

: hello-curses ( -- )
    [
        curses-window new
            "mainwin" >>name
        add-curses-window

        "mainwin" "hi" curses-printf

        2000000 sleep
    ] with-curses ;

[
] [ hello-curses ] unit-test
