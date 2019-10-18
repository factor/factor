USING: tools.interpreter io io.streams.string kernel math
math.private namespaces prettyprint sequences tools.test
continuations math.parser ;
IN: temporary

[ V{ [ "Hello world" print readln break + ] 1 5 } ]
[ 3 [ "Hello world" print readln + ] 1 <breakpoint> ]
unit-test

: run ( -- ) done? [ step-in run ] unless ;

: init-interpreter ( -- )
    V{ } clone V{ } clone V{ } clone namestack catchstack
    f <continuation> meta-interp set ;

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

[ V{ t } ] [
    [ 5 5 number= ] test-interpreter
] unit-test

[ V{ f } ] [
    [ 5 6 number= ] test-interpreter
] unit-test

[ V{ f } ] [
    [ "XYZ" "XYZ" mismatch ] test-interpreter
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

[ V{ 6 } ]
[ [ [ 3 throw ] catch 2 * ] test-interpreter ] unit-test

[ V{ 6 } ]
[ [ [ 3 swap continue-with ] callcc1 2 * ] test-interpreter ] unit-test

: meta-catch meta-interp get continuation-catch ;

! Step back test
[
    init-interpreter
    V{ } clone meta-history set

    V{ f } clone
    V{ } clone
    V{ [ 1 2 3 ] 0 3 } clone
    V{ } clone
    V{ } clone
    f <continuation>
    meta-catch push

    [ ] [ [ 2 2 + throw ] (meta-call) ] unit-test

    [ ] [ step ] unit-test

    [ ] [ step ] unit-test
    
    [ V{ 2 2 } ] [ meta-d ] unit-test

    [ ] [ step ] unit-test
    
    [ V{ 4 } ] [ meta-d ] unit-test
    [ 3 ] [ callframe-scan get ] unit-test
    
    [ ] [ step-back ] unit-test
    [ 2 ] [ callframe-scan get ] unit-test
    
    [ V{ 2 2 } ] [ meta-d ] unit-test
    
    [ ] [ step ] unit-test
    
    [ [ 1 2 3 ] ] [ meta-catch peek continuation-call first ] unit-test

    [ ] [ step ] unit-test
    
    [ [ 1 2 3 ] ] [ callframe get ] unit-test
    [ ] [ step-back ] unit-test
    
    [ V{ 4 } ] [ meta-d ] unit-test
    
    [ [ 1 2 3 ] ] [ meta-catch peek continuation-call first ] unit-test

    [ ] [ step ] unit-test
    
    [ [ 1 2 3 ] ] [ callframe get ] unit-test

] with-scope
