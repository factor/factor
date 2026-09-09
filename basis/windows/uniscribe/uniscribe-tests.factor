USING: accessors colors combinators continuations fonts grouping images
kernel locals math namespaces opengl sequences tools.test
windows.gdi32 windows.offscreen windows.types windows.uniscribe
windows.uniscribe.private ;
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

! UTF-16 hit positions may identify the interior of a surrogate pair.
{ 0 0 1 2 } [
    "\u01f600x" {
        [ 0 >codepoint-index ] [ 1 >codepoint-index ]
        [ 2 >codepoint-index ] [ 3 >codepoint-index ]
    } cleave
] unit-test

:: cluster-hit ( str -- n trailing )
    monospace-font str cached-script-string :> layout
    str length layout line-offset>x 1 - layout x>line-offset ;

{ 0 1 } [ "\u01f600" cluster-hit ] unit-test
{ 0 2 } [ "a\u000301" cluster-hit ] unit-test
{ 0 2 } [ "\u000915\u00093f" cluster-hit ] unit-test

{ B{ 255 128 64 0 255 128 64 64 255 128 64 127 } RGBA } [
    <image> B{ 0 0 0 0 128 128 128 0 255 255 255 0 } >>bitmap
    1 0.5 0.25 0.5 <rgba> color-to-alpha
    [ bitmap>> ] [ component-order>> ] bi
] unit-test

! GDI must receive the foreground composited against an opaque background.
{ t } [
    [
        dup monospace-font 1 0 0 0.5 <rgba> >>foreground
        0 0 1 1 <rgba> >>background set-dc-colors
        0 SetTextColor 0.5 0 0.5 1 <rgba> color>RGB =
    ] with-memory-dc
] unit-test

{ t } [
    monospace-font 1 0 0 0 <rgba> >>foreground
    0 0 1 1 <rgba> >>background "Visible?" cached-script-string
    script-string>image bitmap>> 4 group
    [ 3 head B{ 255 0 0 } = ] all?
] unit-test
