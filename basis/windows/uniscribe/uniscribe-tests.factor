USING: accessors colors combinators continuations destructors fonts grouping images
kernel locals math namespaces opengl sequences sets tools.test
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

! Rasterization can happen after another window changes the global DPI.
:: deferred-dpi-image? ( font text from-scale to-scale -- same? )
    gl-scale-factor get-global :> original
    [ [
        from-scale gl-scale-factor set-global
        font text <script-string> &dispose :> deferred
        font text <script-string> &dispose script-string>image :> expected
        to-scale gl-scale-factor set-global
        deferred script-string>image :> actual
        expected actual [ dim>> ] same?
        expected actual [ bitmap>> ] same? and
        gl-scale-factor get-global to-scale = and
    ] with-destructors ] [ original gl-scale-factor set-global ] finally ;

{ t } [ "Arial" <font> 24 font-with-size "Hello" 1.0 2.0 deferred-dpi-image? ] unit-test
{ t } [
    "Arial" <font> 24 font-with-size 0 0 0 0 <rgba> font-with-background
    "a\u000301" 2.0 1.0 deferred-dpi-image?
] unit-test
{ t } [
    monospace-font "abc אבג" 1 5 COLOR: red <selection>
    1.0 1.5 deferred-dpi-image?
] unit-test

! UTF-16 hit positions may identify the interior of a surrogate pair.
{ 0 0 1 2 } [
    "\u01f600x" {
        [ 0 >codepoint-index ] [ 1 >codepoint-index ]
        [ 2 >codepoint-index ] [ 3 >codepoint-index ]
    } cleave
] unit-test

! Empty strings have font height but no native analysis or bitmap pixels.
{ t t 0 0 0 t } [
    [ monospace-font "" <script-string> &dispose {
      [ size>> [ first zero? ] [ second 0 > ] bi ]
      [ 0 swap line-offset>x ]
      [ 100 swap x>line-offset ]
      [ script-string>image bitmap>> empty? ] } cleave
    ] with-destructors
] unit-test

{ t } [
    monospace-font "" 0 0 COLOR: red <selection> cached-script-string
    script-string>image bitmap>> empty?
] unit-test

{ t } [
    monospace-font "\u00200d" cached-script-string
    script-string>image bitmap>> empty?
] unit-test

! A selection wrapper must not change caret coordinates or Unicode indexes.
{ t 0 2 } [
    monospace-font "a\u000301" 0 2 COLOR: red <selection> cached-script-string
    [ 2 swap line-offset>x 2 monospace-font "a\u000301" cached-script-string line-offset>x = ]
    [ dup 2 swap line-offset>x 1 - swap x>line-offset ] bi
] unit-test

! Failed setup must not register a partially initialized native owner.
{ t } [
    disposables get cardinality
    [ monospace-font "invalid-size" >>size "abc" <script-string> drop ] [ drop ] recover
    disposables get cardinality =
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
