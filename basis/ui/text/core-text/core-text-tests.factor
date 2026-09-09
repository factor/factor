USING: accessors arrays continuations core-text fonts kernel locals
math math.functions math.rectangles namespaces opengl ranges
sequences sets tools.test ui.render ui.text ui.text.core-text
ui.text.core-text.private ui.text.private ;
IN: ui.text.core-text.tests

: test-line ( -- line )
    line new { 0 0 } >>render-loc { 0 0 } >>loc
    { 100000 30 } >>render-ext ;

:: with-text-test-scale ( scale quot -- )
    gl-scale-factor get-global :> previous
    [ scale gl-scale-factor set-global quot call ]
    [ previous gl-scale-factor set-global ] finally ; inline

{ { { 19968 0 } { 20480 0 } { 20992 0 } } } [
    f [
        test-line { 20000 0 } { 1100 30 } <rect> visible-tile-offsets
    ] with-text-test-scale
] unit-test

:: cluster-hit-offsets ( string -- offsets )
    sans-serif-font "Times" >>name 40 >>size :> font
    font string string-dim first ceiling >integer :> width
    -10 width 10 + [a..b] [ font string x>offset ] map members ;

! Mouse hits must not split a surrogate pair, combining sequence or emoji ZWJ
! cluster. Latin ligatures still allow insertion between their letters.
{ t } [
    f [
        { "é" "ạ́" "👩‍💻" "👨‍👩‍👧‍👦" "👍🏽" "🇺🇸" "1️⃣" "क्षि" }
        [ dup cluster-hit-offsets swap length 0 swap 2array = ] all?
    ] with-text-test-scale
] unit-test

{ { 0 1 2 } } [ f [ "fi" cluster-hit-offsets ] with-text-test-scale ] unit-test

{ t } [
    2.0 [
        "👩‍💻" cluster-hit-offsets { 0 3 } =
    ] with-text-test-scale
] unit-test

{ { } } [
    f [ test-line { 0 40 } { 1100 30 } <rect> visible-tile-offsets ] with-text-test-scale
] unit-test

{ { { 19968 0 } { 20480 0 } { 20992 0 } } } [
    2.0 [
        test-line { 10000 0 } { 550 15 } <rect> visible-tile-offsets
    ] with-text-test-scale
] unit-test

{ { 20000.0 20.0 } { 1000.0 100.0 } } [
    { 0 0 } { 1000 100 } <rect>
    -20000 -20 make-translation-matrix modelview-text-clip rect-bounds
] unit-test

{ { 10.0 20.0 } { 500.0 50.0 } } [
    { 20 40 } { 1000 100 } <rect>
    2 2 make-scale-matrix modelview-text-clip rect-bounds
] unit-test

{ { { 0 5 } { 35 40 } } } [
    f [ test-line { 0 5 } >>loc 40 selection-outside-image ] with-text-test-scale
] unit-test

{ { { 20 40 } } } [
    f [ test-line { 0 -10 } >>loc 40 selection-outside-image ] with-text-test-scale
] unit-test

{ { { 0 40 } } } [
    f [ test-line { 0 100 } >>loc 40 selection-outside-image ] with-text-test-scale
] unit-test

{ { -100.0 0.0 } { 100.0 20.0 } } [
    { 0 0 } { 100 20 } <rect>
    -1 1 make-scale-matrix modelview-text-clip rect-bounds
] unit-test

{ f } [
    { 0 0 } { 100 20 } <rect>
    { 1 0.5 0 0 0 1 0 0 0 0 1 0 0 0 0 1 } modelview-text-clip
] unit-test
