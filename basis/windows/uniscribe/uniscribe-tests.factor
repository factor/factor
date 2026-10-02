USING: accessors arrays colors combinators continuations destructors fonts grouping images
kernel locals math namespaces opengl sequences sets sorting tools.test unicode vectors
windows.gdi32 windows.offscreen windows.types windows.uniscribe
windows.uniscribe.private ;
IN: windows.uniscribe.tests

! #2062: supplementary emoji must retain a positive advance, correctly
! indexed end caret, and raster ink with opaque or translucent backgrounds.
:: emoji-width-regression ( alpha -- positive? end? pixels? )
    [
        "monospace" <font> 12 >>size COLOR: black >>foreground
        0.5 0.5 0.5 alpha <rgba> >>background
        "he\u01f346llo" <script-string> &dispose :> script
        script size>> first 0 >
        6 script line-offset>x script size>> first =
        script script-string>image bitmap>> empty? not
    ] with-destructors ;

{ t t t } [ 1.0 emoji-width-regression ] unit-test
{ t t t } [ 0.99 emoji-width-regression ] unit-test

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

! Released native analyses must never reach a Uniscribe API again.
: disposed-script ( -- script )
    monospace-font "abc" <script-string> dup dispose ;

{ f } [ disposed-script ssa>> ] unit-test
[ 1 disposed-script line-offset>x ] [ already-disposed? ] must-fail-with
[ 5 disposed-script x>line-offset ] [ already-disposed? ] must-fail-with
[ disposed-script selection-columns ] [ already-disposed? ] must-fail-with
[ disposed-script script-string>image ] [ already-disposed? ] must-fail-with
[ 1 t disposed-script line-caret>x ] [ already-disposed? ] must-fail-with
[ 5 disposed-script x>line-caret ] [ already-disposed? ] must-fail-with
[ disposed-script uniscribe-selection-spans ] [ already-disposed? ] must-fail-with

! Caret affinity selects either side of a logical bidi boundary.
{ t t } [
    [let
        "Segoe UI" <font> 32 >>size "abc \u0005d0\u0005d1\u0005d2 xyz"
        cached-script-string :> script
        4 t script line-caret>x :> trailing
        4 f script line-caret>x trailing = not
        trailing 1 - script x>line-caret script line-caret>x trailing =
    ]
] unit-test

! Integer GDI hit positions never leak a caret inside a Unicode grapheme.
{ 0 5 } [
    "\u01f469\u00200d\u01f469\u00200d\u01f466"
    [ 2 f rot uniscribe-snap-caret ] [ 2 t rot uniscribe-snap-caret ] bi
] unit-test

{ t t 0 f 3 f } [
    [let
        monospace-font "abc" cached-script-string :> script
        -10 t script line-caret>x 0 script line-offset>x =
        10 f script line-caret>x 3 script line-offset>x =
        -100 script x>line-caret
        10000 script x>line-caret
    ]
] unit-test

{ 0 0 f 0 t f t } [
    [let
        monospace-font "" cached-script-string :> script
        0 t script line-caret>x
        1 script x>line-caret
        0 t 1 script uniscribe-visual-step
        script uniscribe-selection-spans empty?
    ]
] unit-test

:: visual-walk-pixels ( script direction -- pixels )
    direction 0 > [ -1 ] [ script size>> first 1 + ] if
    script x>line-caret :> ( n! affinity! )
    V{ } clone :> pixels
    script string>> length 2 * 4 + [
        n affinity script line-caret>x pixels push
        n affinity direction script uniscribe-visual-step drop affinity! n!
    ] times
    pixels members sort ;

:: complete-visual-walk? ( size text -- ? )
    "Segoe UI" <font> size >>size text cached-script-string :> script
    text length 1 + <iota> [ dup f text uniscribe-snap-caret = ] filter
    [ :> n n f script line-caret>x n t script line-caret>x 2array ] map
    concat members sort :> expected
    script 1 visual-walk-pixels expected =
    script -1 visual-walk-pixels expected = and ;

! Every visual stop is reachable in either direction, including mixed
! lines whose native out-of-bounds sentinel points into a different run.
{ t } [
    { 8 12 24 32 } [| size |
        {
            "abc \u0005d0\u0005d1\u0005d2 xyz"
            "\u000633\u000644\u000627\u000645"
            "\u000633\u000644\u000627\u000645\" xyz"
            "\u01f469\u00200d\u01f469\u00200d\u01f466"
            "a\u000301bc"
            "\u000915\u00093f\u000928\u00093e"
            "abc\u00200bdef"
        } [ size swap complete-visual-walk? ] all?
    ] all?
] unit-test

:: renew-disposed-cache-entry? ( -- fresh? reusable? )
    monospace-font "released cached analysis" cached-script-string :> old
    old dispose
    monospace-font "released cached analysis" cached-script-string :> fresh
    fresh disposed>> not old fresh eq? not and
    fresh monospace-font "released cached analysis" cached-script-string eq? ;

{ t t } [ renew-disposed-cache-entry? ] unit-test

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
