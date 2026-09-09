USING: alien.c-types alien.libraries alien.strings alien.syntax
byte-arrays continuations curses.ffi io io.encodings.utf8 kernel
locals math sequences tools.test unix.types ;
IN: curses.ffi.tests

LIBRARY: libc
FUNCTION-ALIAS: curses-tmpfile FILE* tmpfile ( )
FUNCTION-ALIAS: curses-fclose int fclose ( FILE* stream )
LIBRARY: curses
FUNCTION: int mvwinnstr ( WINDOW* win, int y, int x, char* text, int count )
FUNCTION-ALIAS: wprintw-mixed int wprintw ( WINDOW* win, c-string fmt, ... c-string text, double value, int count )

:: read-window ( win y x count -- text )
    count 1 + <byte-array> :> buffer
    win y x buffer count mvwinnstr drop
    buffer utf8 alien>string ;

:: check-headless-printw ( -- )
    stdscr :> screen
    4 80 0 0 newwin :> window
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
    ] [ window delwin drop ] finally ;

! Every byte of terminal output goes to a temporary file. No tty is opened.
:: with-headless-screen ( quot -- )
    curses-tmpfile :> output
    [
        curses-tmpfile :> input
        [
            "dumb" output input newterm :> screen
            screen [
                [ quot call ] [ endwin drop screen delscreen ] finally
            ] [ "Skipping headless curses checks: dumb terminfo entry is unavailable." print ] if
        ] [ input curses-fclose drop ] finally
    ] [ output curses-fclose drop ] finally ; inline

[ check-headless-printw ] with-headless-screen
