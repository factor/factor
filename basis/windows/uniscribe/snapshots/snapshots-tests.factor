USING: accessors assocs colors combinators destructors fonts fonts.shaping images kernel locals sequences
 tools.test windows.uniscribe windows.uniscribe.private ;
IN: windows.uniscribe.snapshots.tests

:: font-text-snapshot? ( -- same-pixels? same-name? same-size? same-text? )
    [
        "Arial" clone <font> 12 >>size :> font
        "iii" clone :> text
        font text <script-string> &dispose :> script
        font text <script-string> &dispose script-string>image bitmap>> :> expected
        font 48 >>size drop
        CHAR: X 0 font name>> set-nth
        CHAR: W 0 text set-nth
        script script-string>image bitmap>> expected =
        script font>> name>> "Arial" =
        script font>> size>> 12 =
        script string>> "iii" =
    ] with-destructors ;

{ t t t t } [ font-text-snapshot? ] unit-test

:: selection-snapshot? ( -- same-pixels? same-text? same-range? same-color? )
    [
        "Arial" <font> :> font
        "abc" clone 0 1 COLOR: red <selection> :> selection
        font selection <script-string> &dispose :> script
        font selection <script-string> &dispose script-string>image bitmap>> :> expected
        CHAR: W 0 selection string>> set-nth
        selection "longer replacement" >>string 1 >>start 18 >>end COLOR: blue >>color drop
        script script-string>image bitmap>> expected =
        script string>> string>> "abc" =
        script string>> start>> 0 = script string>> end>> 1 = and
        script string>> color>> COLOR: red color=
    ] with-destructors ;

{ t t t t } [ selection-snapshot? ] unit-test

:: stable-cache-key? ( -- same-layout? )
    "Arial" <font> 12 >>size :> font
    "cache snapshot text" clone :> text
    font text cached-script-string :> layout
    font 48 >>size drop CHAR: X 0 text set-nth
    "Arial" <font> 12 >>size "cache snapshot text" cached-script-string
    layout eq? ;

{ t } [ stable-cache-key? ] unit-test

! parsed-color is mutable even though its RGBA value is immutable.
:: color-snapshot? ( -- same-pixels? )
    [
        parsed-color new COLOR: red >>value :> foreground
        "Arial" <font> foreground >>foreground :> font
        font "color" <script-string> &dispose :> script
        font "color" <script-string> &dispose script-string>image bitmap>> :> expected
        foreground COLOR: blue >>value drop
        script script-string>image bitmap>> expected =
    ] with-destructors ;

{ t } [ color-snapshot? ] unit-test

:: mutable-shaped-font ( -- font )
    H{ } clone :> features
    0 "liga" clone features set-at
    "Arial" <font> 20 font-with-tab-width
    "en-us" clone font-with-locale features font-with-features ;

:: shaping-snapshot? ( -- pixels? locale? features? cache? )
    mutable-shaped-font :> font
    font "a\tb" cached-script-string :> script
    mutable-shaped-font "a\tb" <script-string>
    [ script-string>image bitmap>> ] with-disposal :> expected
    60 "tab-width" font shaping-options>> set-at
    CHAR: f 0 font font-locale set-nth
    CHAR: k 0 font font-features keys first set-nth
    2 "liga" font font-features set-at
    script script-string>image bitmap>> expected =
    script font>> font-locale "en-us" =
    script font>> font-features H{ { "liga" 0 } } =
    mutable-shaped-font "a\tb" cached-script-string script eq? ;

{ t t t t } [ shaping-snapshot? ] unit-test

! Metric-only callers may intentionally strip colors from a font.
{ f f } [
    "Arial" <font> strip-font-colors "metrics" <script-string>
    [ font>> [ foreground>> ] [ background>> ] bi ] with-disposal
] unit-test
