USING: accessors kernel namespaces tools.test ui.gadgets
ui.gadgets.frames ui.gadgets.grids ui.gadgets.labels ;
IN: ui.gadgets.frames.tests

[ ] [ <frame> layout ] unit-test

[ t ] [
    <frame>
        "Hello world" <label> @top grid-add
        "Hello world" <label> @center grid-add
        dup pref-dim "dim1" set
        { 1000 1000 } >>dim
        dup layout*
        dup pref-dim "dim2" set
        drop
    "dim1" get "dim2" get =
] unit-test
