USING: alien.c-types arrays kernel locals sequences specialized-arrays
tools.test ui.render ;
SPECIALIZED-ARRAY: float
IN: ui.render.tests

:: check-translation ( matrix offset -- ? )
    matrix clone :> original
    matrix offset first2 translate-matrix
    matrix offset first2 make-translation-matrix mat4-multiply sequence=
    matrix original sequence= and ;

! Check post-multiplication, fractional input conversion, general matrices,
! and preservation of the input used by nested modelview-stack entries.
{ t } [
    {
        { 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 }
        { 0 1 0 0 -1 0 0 0 0 0 1 0 5 8 0 1 }
        { 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
    } [ float-array{ } like ] map [| matrix |
        { { 0 0 } { 0.1 -0.2 } { 2 -3 } { 100000.125 -200.25 } }
        [ matrix swap check-translation ] all?
    ] all?
] unit-test
