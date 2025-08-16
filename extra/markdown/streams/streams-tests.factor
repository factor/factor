USING: colors help.markup inspector io io.styles
markdown.streams tools.test ;

[ [ ] with-markdown-writer ] must-infer

{ "" } [
    [ "" write ] with-markdown-writer
] unit-test

{ "a" } [
    [ CHAR: a write1 ] with-markdown-writer
] unit-test

{
    "[`http://www.funky-town.com/austin`](http://www.funky-town.com/austin)"
} [
    [
        { $url "http://www.funky-town.com/austin" } print-element
    ] with-markdown-writer
] unit-test

{ "`car`" } [
    [
        "car"
        H{ { font-name "monospace" } }
        format
    ] with-markdown-writer
] unit-test

{ "car" } [
    [
        "car"
        H{ { foreground T{ rgba f 1 0 1 1 } } }
        format
    ] with-markdown-writer
] unit-test

{ "cdr" } [
    [
        H{ { page-color T{ rgba f 1 0 1 1 } } }
        [ "cdr" write ] with-nesting
    ] with-markdown-writer
] unit-test

{ "\n\n" } [
    [ H{ } [ ] with-nesting nl ] with-markdown-writer
] unit-test

{ "array with 3 elements\n\n\n| | |\n| - | - |\n| 0 | 1 |\n| 1 | 2 |\n| 2 | 3 |\n\n\n" }
[ [ { 1 2 3 } describe ] with-markdown-writer ] unit-test
