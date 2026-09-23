! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data classes.struct kernel layouts
math tools.test windows.types ;
IN: windows.types.tests

[ S{ RECT { right 100 } { bottom 100 } } ]
[ { 0 0 } { 100 100 } <RECT> ] unit-test

[ S{ RECT { left 100 } { top 100 } { right 200 } { bottom 200 } } ]
[ { 100 100 } { 100 100 } <RECT> ] unit-test

! Windows uses LLP64: handles are pointer-sized, HALF_PTR is half a pointer.
{ t t t } [
    HKEY heap-size cell =
    HALF_PTR heap-size cell 2 / =
    UHALF_PTR heap-size cell 2 / =
] unit-test

! Preserve the high bit of unsigned pointer-sized values.
{ t } [
    1 cell 8 * 1 - shift
    dup WPARAM <ref> WPARAM deref =
] unit-test

{ t } [
    -2147483647 <alien>
    dup HKEY <ref> HKEY deref =
] unit-test
