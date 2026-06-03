! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types colors kernel namespaces opengl
specialized-arrays tools.test ui.gadgets.labels
ui.pens.caching ui.pens.gradient ;

SPECIALIZED-ARRAY: float

! compute-pen
! GL3 mode expands the quad strip into interleaved (x,y,r,g,b,a) triangle
! vertices; legacy mode keeps the flat quad-strip vertices. dim and colors
! are identical on both paths.
gl3-mode? get-global {
    { 0 0 }
    float-array{
        0.0 0.0 1.0 1.0 1.0 1.0 0.0 0.0 1.0 1.0 1.0 1.0
        0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 1.0
        0.0 0.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0 0.0 1.0
    }
    float-array{ 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 1.0 }
} {
    { 0 0 }
    float-array{ 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 }
    float-array{ 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 1.0 }
} ? [
    "hi" <label> { COLOR: white COLOR: black } <gradient>
    [ compute-pen ] keep
    [ last-dim>> ] [ last-vertices>> ] [ last-colors>> ] tri
] unit-test
