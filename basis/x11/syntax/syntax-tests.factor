USING: accessors alien.c-types alien.parser kernel sequences tools.test words
x11.xlib ;
IN: x11.syntax.tests

! X-FUNCTION: must preserve the fixed-argument count from FUNCTION:.
{ 1 } [ \ XCreateIC def>> 4 swap nth ] unit-test
{ f } [ \ XSetErrorHandler def>> 4 swap nth ] unit-test
{ t } [
    \ XSetErrorHandler def>> first
    dup wrapper? [ wrapped>> ] when pointer?
] unit-test
