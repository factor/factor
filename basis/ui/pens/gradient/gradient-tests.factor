USING: tools.test ui.pens.gradient ui.pens.gradient.private
colors.constants specialized-arrays alien.c-types ;
SPECIALIZED-ARRAY: float
IN: ui.pens.gradient.tests

[
    float-array{
        0.0
        0.0
        0.0
        100.0
        50.0
        0.0
        50.0
        100.0
        100.0
        0.0
        100.0
        100.0
    }
] [
    { 1 0 } { 100 100 } { COLOR: red COLOR: green COLOR: blue }
    gradient-vertices
] unit-test
