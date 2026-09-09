USING: accessors continuations fonts fonts.shaping kernel locals math math.functions
namespaces opengl tools.test ui.text ;
IN: ui.text.directwrite.tests

! UI coordinates stay logical as native layouts change backing scale.
:: scaled-tab-caret ( -- x index )
    gl-scale-factor get-global :> original
    [
        1.5 gl-scale-factor set-global
        2 sans-serif-font 32 font-with-tab-width "a\tb" offset>x
        32 sans-serif-font 32 font-with-tab-width "a\tb" x>offset
    ] [ original gl-scale-factor set-global ] finally ;

{ t 2 } [ scaled-tab-caret [ 32.0 0.01 ~ ] dip ] unit-test

{ t } [
    sans-serif-font right-to-left font-with-direction "abc אבג"
    [ 0 -rot offset>x ] [ 0 -rot x>offset ] 2bi
    [ 0 > ] [ 0 > ] bi* and
] unit-test
