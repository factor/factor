USING: accessors continuations fonts kernel locals math namespaces opengl
tools.test windows.uniscribe ;
IN: windows.uniscribe.tests

! Layouts must not reuse the raster size from a different monitor.
:: test-monitor-font-scales ( -- distinct? larger? reused? )
    monospace-font :> font
    gl-scale-factor get-global :> original-scale
    [
        f gl-scale-factor set-global
        font "Monitor DPI" cached-script-string :> normal
        1.5 gl-scale-factor set-global
        font "Monitor DPI" cached-script-string :> scaled
        1.0 gl-scale-factor set-global
        font "Monitor DPI" cached-script-string :> normal-again
        normal scaled eq? not
        scaled metrics>> height>> normal metrics>> height>> >
        normal normal-again eq?
    ] [ original-scale gl-scale-factor set-global ] finally ;

{ t t t } [ test-monitor-font-scales ] unit-test
