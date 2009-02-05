IN: ui.gadgets.grid-lines.tests
USING: tools.test ui.gadgets ui.gadgets.grid-lines ui.gadgets.grid-lines.private
ui.gadgets.grids.private accessors arrays ui.gadgets.grids sorting kernel ;

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
        { { 5 5 } { 5 115 } }
        { { 5 5 } { 115 5 } }
        { { 5 115 } { 115 115 } }
        { { 115 5 } { 115 115 } }
    }
] [
    100x100 1array
    1array
    <grid>
    { 10 10 } >>gap
    dup prefer
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