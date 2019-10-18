USING: accessors kernel namespaces tools.test ui.gadgets
ui.gadgets.frames ui.gadgets.grids ui.gadgets.labels ;

{ } [ 3 3 <frame> { 1 1 } >>filled-cell layout ] unit-test

{ { 1000 1000 } } [
    1 1 <frame>
    { 0 0 } >>filled-cell
    <gadget> dup "c" set { 0 0 } grid-add
    { 1000 1000 } >>dim
    layout
    "c" get dim>>
] unit-test

{ t } [
    1 2 <frame>
        { 0 0 } >>filled-cell
        "Hello world" <label> { 0 0 } grid-add
        "Hello world" <label> { 0 1 } grid-add
        dup pref-dim "dim1" set
        { 1000 1000 } >>dim
        dup layout*
        dup pref-dim "dim2" set
        drop
    "dim1" get "dim2" get =
] unit-test

{ { 5 20 } { 20 20 } } [
    2 3 <frame>
    { 0 1 } >>filled-cell
    { 5 5 } >>gap
    <gadget> { 10 10 } >>dim { 0 0 } grid-add
    <gadget> { 10 10 } >>dim dup "c" set { 0 1 } grid-add
    <gadget> { 10 20 } >>dim { 0 2 } grid-add
    <gadget> { 30 10 } >>dim { 1 1 } grid-add
    { 65 70 } >>dim
    layout
    "c" get [ loc>> ] [ dim>> ] bi
] unit-test
