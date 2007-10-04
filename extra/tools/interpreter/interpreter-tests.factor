USING: tools.interpreter io io.streams.string kernel math
math.private namespaces prettyprint sequences tools.test
continuations math.parser threads arrays
tools.interpreter.debug ;
IN: temporary

[ "Ooops" throw ] break-hook set

[ { } ] [
    [ ] test-interpreter
] unit-test

[ { 1 } ] [
    [ 1 ] test-interpreter
] unit-test

[ { 1 2 3 } ] [
    [ 1 2 3 ] test-interpreter
] unit-test

[ { "Yo" 2 } ] [
    [ 2 >r "Yo" r> ] test-interpreter
] unit-test

[ { 2 } ] [
    [ t [ 2 ] [ "hi" ] if ] test-interpreter
] unit-test

[ { "hi" } ] [
    [ f [ 2 ] [ "hi" ] if ] test-interpreter
] unit-test

[ { 4 } ] [
    [ 2 2 fixnum+ ] test-interpreter
] unit-test

: foo 2 2 fixnum+ ;

[ { 8 } ] [
    [ foo 4 fixnum+ ] test-interpreter
] unit-test

[ { C{ 1 1.5 } { } C{ 1 1.5 } { } } ] [
    [ C{ 1 1.5 } { } 2dup ] test-interpreter
] unit-test

[ { t } ] [
    [ 5 5 number= ] test-interpreter
] unit-test

[ { f } ] [
    [ 5 6 number= ] test-interpreter
] unit-test

[ { f } ] [
    [ "XYZ" "XYZ" mismatch ] test-interpreter
] unit-test

[ { t } ] [
    [ "XYZ" "XYZ" sequence= ] test-interpreter
] unit-test

[ { t } ] [
    [ "XYZ" "XYZ" = ] test-interpreter
] unit-test

[ { f } ] [
    [ "XYZ" "XuZ" = ] test-interpreter
] unit-test

[ { 4 } ] [
    [ 2 2 + ] test-interpreter
] unit-test

[ { } 2 ] [
    2 "x" set [ [ 3 "x" set ] with-scope ] test-interpreter "x" get
] unit-test

[ { 3 } ] [
    [ 3 "x" set "x" get ] test-interpreter
] unit-test

[ { "hi\n" } ] [
    [ [ "hi" print ] string-out ] test-interpreter
] unit-test

[ { "4\n" } ] [
    [ [ 2 2 + number>string print ] string-out ] test-interpreter
] unit-test

[ { 1 2 3 } ] [
    [ { 1 2 3 } set-datastack ] test-interpreter
] unit-test

[ { 6 } ]
[ [ 3 [ nip continue ] callcc0 2 * ] test-interpreter ] unit-test

[ { 6 } ]
[ [ [ 3 swap continue-with ] callcc1 2 * ] test-interpreter ] unit-test

[ { 6 } ]
[ [ [ 3 throw ] catch 2 * ] test-interpreter ] unit-test

[ { "{ 1 2 3 }\n" } ] [
    [ [ { 1 2 3 } . ] string-out ] test-interpreter
] unit-test

: meta-catch interpreter get continuation-catch ;

! Step back test
! [
!     init-interpreter
!     V{ } clone meta-history set
! 
!     V{ f } clone
!     V{ } clone
!     V{ [ 1 2 3 ] 0 3 } clone
!     V{ } clone
!     V{ } clone
!     f <continuation>
!     meta-catch push
! 
!     [ ] [ [ 2 2 + throw ] (meta-call) ] unit-test
! 
!     [ ] [ step ] unit-test
! 
!     [ ] [ step ] unit-test
!     
!     [ { 2 2 } ] [ meta-d ] unit-test
! 
!     [ ] [ step ] unit-test
!     
!     [ { 4 } ] [ meta-d ] unit-test
!     [ 3 ] [ callframe-scan get ] unit-test
!     
!     [ ] [ step-back ] unit-test
!     [ 2 ] [ callframe-scan get ] unit-test
!     
!     [ { 2 2 } ] [ meta-d ] unit-test
!     
!     [ ] [ step ] unit-test
!     
!     [ [ 1 2 3 ] ] [ meta-catch peek continuation-call first ] unit-test
! 
!     [ ] [ step ] unit-test
!     
!     [ [ 1 2 3 ] ] [ callframe get ] unit-test
!     [ ] [ step-back ] unit-test
!     
!     [ { 4 } ] [ meta-d ] unit-test
!     
!     [ [ 1 2 3 ] ] [ meta-catch peek continuation-call first ] unit-test
! 
!     [ ] [ step ] unit-test
!     
!     [ [ 1 2 3 ] ] [ callframe get ] unit-test
! 
! ] with-scope
