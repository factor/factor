USING: accessors colors combinators fonts images kernel math sequences tools.test
ui.text ui.text.android ui.text.private ;
IN: ui.text.android.tests

{ t } [ sans-serif-font "A😀ב" string-dim [ 0 > ] all? ] unit-test

{ t } [
    2 sans-serif-font "A😀ב" offset>x
    dup 0 > swap sans-serif-font "A😀ב" x>offset 2 = and
] unit-test

{ t } [
    2 5 sans-serif-font "abc אבג xyz" selection-spans
    [ length 2 >= ] [ [ first2 <= ] all? ] bi and
] unit-test

{ t } [
    sans-serif-font clone
        COLOR: white >>foreground COLOR: red >>background
    "text 😀" 1 5 COLOR: blue <selection> string>image drop
    [ dim>> product 0 > ]
    [ [ bitmap>> length ] [ bytes-per-image ] bi = ] bi and
] unit-test
