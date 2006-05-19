IN: temporary
USING: errors interpreter io kernel math math-internals
namespaces prettyprint sequences test ;

: done-all? ( -- ? ) done? meta-c get empty? and ;

: run ( -- ) done-all? [ next do run ] unless ;

: init-interpreter ( -- )
    V{ } clone meta-d set
    V{ } clone meta-r set
    V{ } clone meta-c set
    namestack meta-name set
    catchstack meta-catch set ;

: test-interpreter
    init-interpreter (meta-call) run meta-d get ;

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

[ V{ t } ] [
    [ "XYZ" "XYZ" = ] test-interpreter
] unit-test

[ V{ f } ] [
    [ "XYZ" "XuZ" = ] test-interpreter
] unit-test

[ V{ C{ 1 1.5 } { } C{ 1 1.5 } { } } ] [
    [ C{ 1 1.5 } { } 2dup ] test-interpreter
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
