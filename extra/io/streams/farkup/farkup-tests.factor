USING: colors help.markup inspector io io.styles
io.streams.farkup tools.test ;

[ [ ] with-farkup-writer ] must-infer

{ "" } [
    [ "" write ] with-farkup-writer
] unit-test

{ "a" } [
    [ CHAR: a write1 ] with-farkup-writer
] unit-test

{
    "[[http://www.funky-town.com/austin|%http://www.funky-town.com/austin%]]"
} [
    [
        { $url "http://www.funky-town.com/austin" } print-element
    ] with-farkup-writer
] unit-test

{ "%car%" } [
    [
        "car"
        H{ { font-name "monospace" } }
        format
    ] with-farkup-writer
] unit-test

{ "car" } [
    [
        "car"
        H{ { foreground T{ rgba f 1 0 1 1 } } }
        format
    ] with-farkup-writer
] unit-test

{ "cdr" } [
    [
        H{ { page-color T{ rgba f 1 0 1 1 } } }
        [ "cdr" write ] with-nesting
    ] with-farkup-writer
] unit-test

{ "\n\n" } [
    [ H{ } [ ] with-nesting nl ] with-farkup-writer
] unit-test

{ "array with 3 elements\n\n\n| | |\n| - | - |\n| 0 | 1 |\n| 1 | 2 |\n| 2 | 3 |\n\n\n" }
[ [ { 1 2 3 } describe ] with-farkup-writer ] unit-test
