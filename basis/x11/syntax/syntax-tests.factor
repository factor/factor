USING: accessors alien.c-types alien.parser alien.syntax kernel sequences tools.test words
x11.io x11.syntax x11.xlib ;
IN: x11.syntax.tests

! X-FUNCTION: must preserve the fixed-argument count from FUNCTION:.
{ 1 } [ \ XCreateIC def>> 4 swap nth ] unit-test
{ f } [ \ XSetErrorHandler def>> 4 swap nth ] unit-test
{ t } [
    \ XSetErrorHandler def>> first
    dup wrapper? [ wrapped>> ] when pointer?
] unit-test

! Exercise declaration construction as well as existing Xlib words.
X-FUNCTION: int x11-parser-fixed ( int value )
X-FUNCTION: int x11-parser-varargs ( int tag, ... int value, double scale )

{ ( value -- int ) } [ \ x11-parser-fixed "declared-effect" word-prop ] unit-test
{ ( tag value scale -- int ) } [ \ x11-parser-varargs "declared-effect" word-prop ] unit-test
{ f } [ \ x11-parser-fixed def>> 4 swap nth ] unit-test
{ 1 } [ \ x11-parser-varargs def>> 4 swap nth ] unit-test
{ t } [ \ x11-parser-varargs def>> last \ awaken-event-loop eq? ] unit-test
