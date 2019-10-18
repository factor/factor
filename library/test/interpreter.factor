IN: temporary
USING: errors interpreter io kernel math math-internals
namespaces prettyprint sequences test ;

: run ( -- ) done? [ step-in run ] unless ;

: init-interpreter ( -- )
    V{ } clone V{ } clone V{ } clone namestack catchstack
    <continuation> meta-interp set ;

: test-interpreter
    init-interpreter (meta-call) run meta-d ;

[ V{ } ] [
    [ ] test-interpreter
] unit-test

[ V{ 1 } ] [
    [ 1 ] test-interpreter
] unit-test

[ V{ 1 2 3 } ] [
    [ 1 2 3 ] test-interpreter
] unit-test

[ V{ "Yo" 2 } ] [
    [ 2 >r "Yo" r> ] test-interpreter
] unit-test

[ V{ 2 } ] [
    [ t [ 2 ] [ "hi" ] if ] test-interpreter
] unit-test

[ V{ "hi" } ] [
    [ f [ 2 ] [ "hi" ] if ] test-interpreter
] unit-test

[ V{ 4 } ] [
    [ 2 2 fixnum+ ] test-interpreter
] unit-test

: foo 2 2 fixnum+ ;

[ V{ 8 } ] [
    [ foo 4 fixnum+ ] test-interpreter
] unit-test

[ V{ C{ 1 1.5 } { } C{ 1 1.5 } { } } ] [
    [ C{ 1 1.5 } { } 2dup ] test-interpreter
] unit-test

[ V{ 3 4 1 2 } ] [
    [ 1 2 3 4 2swap ] test-interpreter
] unit-test

[ V{ t } ] [
    [ 5 5 number= ] test-interpreter
] unit-test

[ V{ f } ] [
    [ 5 6 number= ] test-interpreter
] unit-test

[ V{ -1 } ] [
    [ "XYZ" "XYZ" 3 (mismatch) ] test-interpreter
] unit-test

[ V{ t } ] [
    [ "XYZ" "XYZ" sequence= ] test-interpreter
] unit-test

[ V{ t } ] [
    [ "XYZ" "XYZ" = ] test-interpreter
] unit-test

[ V{ f } ] [
    [ "XYZ" "XuZ" = ] test-interpreter
] unit-test

[ V{ 4 } ] [
    [ 2 2 + ] test-interpreter
] unit-test

[ V{ } 2 ] [
    2 "x" set [ [ 3 "x" set ] with-scope ] test-interpreter "x" get
] unit-test

[ V{ 3 } ] [
    [ 3 "x" set "x" get ] test-interpreter
] unit-test

[ V{ "hi\n" } ] [
    [ [ "hi" print ] string-out ] test-interpreter
] unit-test

[ V{ "4\n" } ] [
    [ [ 2 2 + number>string print ] string-out ] test-interpreter
] unit-test
