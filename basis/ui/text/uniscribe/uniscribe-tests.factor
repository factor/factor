USING: accessors fonts kernel locals math sequences tools.test ui.text ;
IN: ui.text.uniscribe.tests

! Line width must describe the shaped string, not a placeholder value.
{ t } [
    sans-serif-font "iii" [ line-metrics width>> ] [ text-width ] 2bi =
] unit-test

:: near-cluster-end ( str -- n )
    str length monospace-font str offset>x 1 -
    monospace-font str x>offset ;

{ 1 } [ "\u01f600" near-cluster-end ] unit-test
{ 2 } [ "a\u000301" near-cluster-end ] unit-test
{ 2 } [ "\u000915\u00093f" near-cluster-end ] unit-test
{ 0 } [ -100 monospace-font "abc" x>offset ] unit-test
{ 3 } [ 10000 monospace-font "abc" x>offset ] unit-test

{ t } [
    sans-serif-font "A much longer line"
    [ line-metrics width>> ] [ text-width ] 2bi =
] unit-test

{ 0 } [ sans-serif-font "" line-metrics width>> ] unit-test

! Cap/x heights must come from the font and scale with its size.
{ t } [
    sans-serif-font 12 font-with-size "Hx" line-metrics cap-height>>
    sans-serif-font 36 font-with-size "Hx" line-metrics cap-height>> <
] unit-test

{ t } [
    sans-serif-font 12 font-with-size "Hx" line-metrics x-height>>
    sans-serif-font 36 font-with-size "Hx" line-metrics x-height>> <
] unit-test

{ t } [
    sans-serif-font [ font-metrics cap-height>> ]
    [ "Hx" line-metrics cap-height>> ] bi =
] unit-test
