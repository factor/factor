! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants kernel
specialized-arrays.instances.alien.c-types.float tools.test
ui.gadgets.labels ui.pens.caching ui.pens.gradient ;
IN: ui.pens.caching.tests

! compute-pen
{
    { 0 0 }
    float-array{ 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 }
    float-array{ 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 1.0 }
} [
    "hi" <label> { COLOR: white COLOR: black } <gradient>
    [ compute-pen ] keep
    [ last-dim>> ] [ last-vertices>> ] [ last-colors>> ] tri
] unit-test
