! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types colors kernel
specialized-arrays tools.test ui.gadgets.labels
ui.pens.caching ui.pens.gradient ;

SPECIALIZED-ARRAY: float

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
