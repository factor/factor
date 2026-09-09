USING: alien.c-types curses.ffi kernel tools.test ;
QUALIFIED: alien.varargs
IN: curses.ffi.tests

{ t } [
    va_list lookup-c-type alien.varargs:va_list lookup-c-type eq?
] unit-test
