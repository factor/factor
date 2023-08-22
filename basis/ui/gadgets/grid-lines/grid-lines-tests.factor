USING: accessors arrays kernel sorting tools.test ui.gadgets
ui.gadgets.grid-lines.private ui.gadgets.grids ;
IN: ui.gadgets.grid-lines.tests

: 100x100 ( -- gadget )
    <gadget> { 100 100 } >>dim ;

{
    {
        { { 0.0 0.0 } { 0.0 100.0 } }
        { { 0.0 0.0 } { 100.0 0.0 } }
        { { 0.0 100.0 } { 100.0 100.0 } }
        { { 100.0 0.0 } { 100.0 100.0 } }
    }
} [
    100x100 1array
    1array
    <grid>
    { 100 100 } >>dim
    compute-grid-lines sort
] unit-test

{
    {
        { { 5.0 5.0 } { 5.0 115.0 } }
        { { 5.0 5.0 } { 115.0 5.0 } }
        { { 5.0 115.0 } { 115.0 115.0 } }
        { { 115.0 5.0 } { 115.0 115.0 } }
    }
} [
    100x100 1array
    1array
    <grid>
    { 10 10 } >>gap
    dup prefer
    compute-grid-lines sort
] unit-test

{
    {
        { { 0.0 0.0 } { 0.0 200.0 } }
        { { 0.0 0.0 } { 200.0 0.0 } }
        { { 0.0 100.0 } { 200.0 100.0 } }
        { { 0.0 200.0 } { 200.0 200.0 } }
        { { 100.0 0.0 } { 100.0 200.0 } }
        { { 200.0 0.0 } { 200.0 200.0 } }
    }
} [
    100x100 100x100 2array
    100x100 100x100 2array
    2array
    <grid>
    { 200.0 200 } >>dim
    compute-grid-lines sort
] unit-test

{
    {
        { { 0.5 0.5 } { 0.5 2.5 } }
        { { 2.5 0.5 } { 2.5 2.5 } }
        { { 0.5 0.5 } { 2.5 0.5 } }
        { { 0.5 2.5 } { 2.5 2.5 } }
    }
} [
    <gadget> { 1 1 } >>dim
    1array 1array <grid> { 1 1 } >>gap
    dup prefer
    compute-grid-lines
] unit-test
