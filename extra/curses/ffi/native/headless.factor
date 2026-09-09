USING: alien.c-types alien.libraries alien.strings alien.syntax
arrays byte-arrays continuations curses.ffi environment io
io.encodings.utf8 io.launcher io.pathnames kernel locals math
sequences tools.test unix.types ;
IN: curses.ffi.tests

LIBRARY: libc
FUNCTION-ALIAS: curses-tmpfile FILE* tmpfile ( )
FUNCTION-ALIAS: curses-fclose int fclose ( FILE* stream )
LIBRARY: curses
FUNCTION: int mvwinnstr ( WINDOW* win, int y, int x, char* text, int count )
FUNCTION-ALIAS: wprintw-literal int wprintw ( WINDOW* win, c-string fmt, ... )
FUNCTION-ALIAS: tparm-position c-string tparm ( c-string capability, ... long row, long column )
FUNCTION-ALIAS: test-tigetstr char* tigetstr ( c-string name )
FUNCTION-ALIAS: tparm-text c-string tparm ( c-string capability, ... long key, c-string text )
FUNCTION-ALIAS: wprintw-mixed int wprintw ( WINDOW* win, c-string fmt, ... c-string text, double value, int count )

ERROR: curses-test-allocation-failed resource ;

: test-tmpfile ( -- file )
    curses-tmpfile dup [ "tmpfile" curses-test-allocation-failed ] unless ;

:: read-window ( win y x count -- text )
    count 1 + <byte-array> :> buffer
    win y x buffer count mvwinnstr drop
    buffer utf8 alien>string ;

:: check-headless-printw ( -- )
    stdscr :> screen
    4 80 0 0 newwin :> window
    window [ "newwin" curses-test-allocation-failed ] unless
    [
        { 0 "value=12345" } [
            screen werase drop "value=%d" 12345 printw
            screen 0 0 11 read-window
        ] unit-test
        { 0 "value=-2468" } [
            window werase drop window "value=%d" -2468 wprintw
            window 0 0 11 read-window
        ] unit-test
        { 0 "value=13579" } [
            screen werase drop 1 2 "value=%d" 13579 mvprintw
            screen 1 2 11 read-window
        ] unit-test
        { 0 "value=-9753" } [
            window werase drop window 1 2 "value=%d" -9753 mvwprintw
            window 1 2 11 read-window
        ] unit-test
        { 0 "value=1.25/7" } [
            window werase drop window "%s=%.2f/%d" "value" 1.25 7 wprintw-mixed
            window 0 0 12 read-window
        ] unit-test
        { 0 "literal" } [
            window werase drop window "literal" wprintw-literal
            window 0 0 7 read-window
        ] unit-test
        { "11:99" } [
            "%p1%d:%p9%d" 11 22 33 44 55 66 77 88 99 tparm
        ] unit-test
        { "3:5" } [ "%p1%d:%p2%d" 3 5 tparm-position ] unit-test
        { "7:text" } [ "pfkey" test-tigetstr 7 "text" tparm-text ] unit-test
    ] [ window delwin drop ] finally ;

! Every byte of terminal output goes to a temporary file. No tty is opened.
:: with-headless-screen ( quot -- )
    test-tmpfile :> output
    [
        test-tmpfile :> input
        [
            "factor-ffi-test" output input newterm :> screen
            screen [
                [ quot call ] [ endwin drop screen delscreen ] finally
            ] [ "test terminfo" curses-test-allocation-failed ] if
        ] [ input curses-fclose drop ] finally
    ] [ output curses-fclose drop ] finally ; inline

[
    "tic" "-o" "." absolute-path
    "resource:extra/curses/ffi/native/factor-test.ti" absolute-path
    4array try-process
    "." absolute-path "TERMINFO" [
        [ check-headless-printw ] with-headless-screen
    ] with-os-env
] with-test-directory
