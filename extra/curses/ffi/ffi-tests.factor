USING: accessors alien.c-types alien.libraries curses.ffi effects io kernel
parser sequences tools.test words ;
QUALIFIED: alien.varargs
IN: curses.ffi.tests

{ t } [
    va_list lookup-c-type alien.varargs:va_list lookup-c-type eq?
] unit-test

! The marker records how many parameters precede the C ellipsis.
{ { 1 2 3 4 1 } } [
    { printw wprintw mvprintw mvwprintw tparm }
    [ def>> 4 swap nth ] map
] unit-test
{ ( fmt value -- int ) } [ \ printw "declared-effect" word-prop ] unit-test
{ ( win fmt value -- int ) } [ \ wprintw "declared-effect" word-prop ] unit-test
{ ( y x fmt value -- int ) } [ \ mvprintw "declared-effect" word-prop ] unit-test
{ ( win y x fmt value -- int ) } [ \ mvwprintw "declared-effect" word-prop ] unit-test
{ { f f } } [
    { vwprintw vw_printw } [ def>> 4 swap nth ] map
] unit-test

"curses" library-dll dll-valid? [
    "resource:extra/curses/ffi/native/headless.factor" run-test-file
] [ "Skipping headless curses checks: ncurses library is unavailable." print ] if
