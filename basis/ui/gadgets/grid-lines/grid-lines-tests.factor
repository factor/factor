IN: ui.gadgets.grid-lines.tests
USING: tools.test ui.gadgets.grid-lines ui.gadgets.grid-lines.tests colors ;

[ { 1 3 5 7 9 } ] [
    8 { 0 2 4 6 } horizontal { 2 2 } grid-line-offsets
] unit-test

: 100x100 ( -- gadget ) <gadget> { 100 100 } >>dim ;

[
    {
        { { 0 0 } { 0 100 } }
        { { 0 0 } { 100 0 } }
        { { 0 100 } { 100 100 } }
        { { 100 0 } { 100 100 } }
    }
] [
    100x100 1array
    1array
    <grid>
    { 100 100 } >>dim
    compute-grid-lines natural-sort
] unit-test

[
    {
        { { 0 0 } { 0 200 } }
        { { 0 0 } { 200 0 } }
        { { 0 100 } { 200 100 } }
        { { 0 200 } { 200 200 } }
        { { 100 0 } { 100 200 } }
        { { 200 0 } { 200 200 } }
    }
] [
    100x100 100x100 2array
    100x100 100x100 2array
    2array
    <grid>
    { 200 200 } >>dim
    compute-grid-lines natural-sort
] unit-test