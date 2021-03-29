IN: ui.commands.tests
USING: ui.commands ui.gestures tools.test help.markup io
io.streams.string system kernel ;

{ "Press Button 2" } [ T{ button-down f f 2 } gesture>string ] unit-test

: com-test-1 ( -- ) ;

\ com-test-1 H{ } define-command

{ [ 3 com-test-1 ] } [ 3 \ com-test-1 command-quot ] unit-test

: com-test-2 ( -- ) ;

\ com-test-2 H{ { +nullary+ t } } define-command

{ [ com-test-2 ] } [ 3 \ com-test-2 command-quot ] unit-test

SYMBOL: testing

testing "testing" "hey" {
    { T{ key-down f { C+ } "x" } com-test-1 }
} define-command-map

os macosx? [
    { "⌘A" } [ T{ key-down f { M+ } "a" } gesture>string ] unit-test
    { "B" } [ T{ key-down f f "b" } gesture>string ] unit-test

    { "⌃X" } [
        [
            { $command testing "testing" com-test-1 } print-element
        ] with-string-writer
    ] unit-test
] [
    { "A+a" } [ T{ key-down f { A+ } "a" } gesture>string ] unit-test
    { "b" } [ T{ key-down f f "b" } gesture>string ] unit-test

    { "C+x" } [
        [
            { $command testing "testing" com-test-1 } print-element
        ] with-string-writer
    ] unit-test
] if

: com-foo. ( -- ) ;

{ "Foo" } [ \ com-foo. command-name ] unit-test
