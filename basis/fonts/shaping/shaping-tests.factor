USING: accessors assocs combinators fonts fonts.shaping kernel tools.test ;
IN: fonts.shaping.tests

{ f f H{ } "en-us" t } [
    monospace-font {
        [ font-text-direction ] [ font-tab-width ] [ font-features ]
        [ font-locale ] [ font-color-fonts? ]
    } cleave
] unit-test

{ right-to-left 40 H{ { "liga" 0 } } "ar-sa" f } [
    monospace-font right-to-left font-with-direction
    40 font-with-tab-width H{ { "liga" 0 } } font-with-features
    "ar-sa" font-with-locale f font-with-color-fonts {
        [ font-text-direction ] [ font-tab-width ] [ font-features ]
        [ font-locale ] [ font-color-fonts? ]
    } cleave
] unit-test

! Updating options leaves the source font and its associations untouched.
{ t f } [
    monospace-font f font-with-color-fonts
    dup t font-with-color-fonts font-color-fonts? swap font-color-fonts?
] unit-test

! Derived UI styles inherit omitted options and honor explicit false overrides.
{ right-to-left 24 f } [
    monospace-font right-to-left font-with-direction 24 font-with-tab-width
    font new f font-with-color-fonts derive-font
    [ font-text-direction ] [ font-tab-width ] [ font-color-fonts? ] tri
] unit-test

{ left-to-right } [
    monospace-font right-to-left font-with-direction
    font new left-to-right font-with-direction derive-font font-text-direction
] unit-test

[ monospace-font "rtl" font-with-direction ] [ invalid-text-direction? ] must-fail-with
[ monospace-font -1 font-with-tab-width ] [ invalid-tab-width? ] must-fail-with
[ monospace-font 1/0. font-with-tab-width ] [ invalid-tab-width? ] must-fail-with
[ monospace-font 0/0. font-with-tab-width ] [ invalid-tab-width? ] must-fail-with
[ monospace-font H{ { "bad" 1 } } font-with-features ] [ invalid-font-features? ] must-fail-with
[ monospace-font H{ { "liga" -1 } } font-with-features ] [ invalid-font-features? ] must-fail-with
