USING: kernel sequences shapefiles tools.test ;
IN: shapefiles.tests

: save-and-load? ( shapes -- ? )
    [
        [ save-shapes ] [ load-shapes sequence= ] 2bi
    ] with-test-file ;

{ t } [
    { null-shape } save-and-load?
] unit-test

{ t } [
    { null-shape T{ point f 1.0 2.0 } } save-and-load?
] unit-test

{ t } [
    { T{ point-m f 1.0 2.0 3.0 } } save-and-load?
] unit-test

{ t } [
    { T{ point-z f 1.0 2.0 3.0 4.0 } } save-and-load?
] unit-test

{ t } [
    { T{ polygon
        { box { 1.0 3.0 2.0 4.0 } }
        { parts { } }
        { points { T{ point f 1.0 2.0 } T{ point f 3.0 4.0 } } } }
    } save-and-load?
] unit-test

{ t } [
    { T{ polygon-m
        { box { 1.0 3.0 2.0 4.0 } }
        { parts { } }
        { points { T{ point f 1.0 2.0 } T{ point f 3.0 4.0 } } }
        { m-range { 10.0 20.0 } }
        { m-array { 10.0 20.0 } } }
    } save-and-load?
] unit-test

{ t } [
    { T{ polygon-z
        { box { 1.0 3.0 2.0 4.0 } }
        { parts { } }
        { points { T{ point f 1.0 2.0 } T{ point f 3.0 4.0 } } }
        { z-range { -10.0 -20.0 } }
        { z-array { -10.0 -20.0 } }
        { m-range { 10.0 20.0 } }
        { m-array { 10.0 20.0 } } }
    } save-and-load?
] unit-test
