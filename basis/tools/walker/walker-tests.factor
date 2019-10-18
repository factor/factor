USING: tools.walker io io.streams.string kernel math
math.private namespaces prettyprint sequences tools.test
continuations math.parser threads arrays tools.walker.debug
generic.single sequences.private kernel.private
tools.continuations accessors words combinators ;
IN: tools.walker.tests

[ { } ] [
    [ ] test-walker
] unit-test

[ { 1 } ] [
    [ 1 ] test-walker
] unit-test

[ { 1 2 3 } ] [
    [ 1 2 3 ] test-walker
] unit-test

[ { "Yo" 2 } ] [
    [ 2 [ "Yo" ] dip ] test-walker
] unit-test

[ { "Yo" 2 3 } ] [
    [ 2 [ "Yo" ] dip 3 ] test-walker
] unit-test

[ { 2 } ] [
    [ t [ 2 ] [ "hi" ] if ] test-walker
] unit-test

[ { "hi" } ] [
    [ f [ 2 ] [ "hi" ] if ] test-walker
] unit-test

[ { 4 } ] [
    [ 2 2 fixnum+ ] test-walker
] unit-test

: foo ( -- x ) 2 2 fixnum+ ;

[ { 8 } ] [
    [ foo 4 fixnum+ ] test-walker
] unit-test

[ { C{ 1 1.5 } { } C{ 1 1.5 } { } } ] [
    [ C{ 1 1.5 } { } 2dup ] test-walker
] unit-test

[ { t } ] [
    [ 5 5 number= ] test-walker
] unit-test

[ { f } ] [
    [ 5 6 number= ] test-walker
] unit-test

[ { 0 } ] [
    [ 0 { array-capacity } declare ] test-walker
] unit-test

[ { f } ] [
    [ "XYZ" "XYZ" mismatch ] test-walker
] unit-test

[ { t } ] [
    [ "XYZ" "XYZ" sequence= ] test-walker
] unit-test

[ { t } ] [
    [ "XYZ" "XYZ" = ] test-walker
] unit-test

[ { f } ] [
    [ "XYZ" "XuZ" = ] test-walker
] unit-test

[ { 4 } ] [
    [ 2 2 + ] test-walker
] unit-test

[ { 3 } ] [
    [ [ 3 "x" set "x" get ] with-scope ] test-walker
] unit-test

[ { "hi\n" } ] [
    [ [ "hi" print ] with-string-writer ] test-walker
] unit-test

[ { "4\n" } ] [
    [ [ 2 2 + number>string print ] with-string-writer ] test-walker
] unit-test
                                                            
[ { 1 2 3 } ] [
    [ { 1 2 3 } set-datastack ] test-walker
] unit-test

[ { 6 } ]
[ [ 3 [ nip continue ] callcc0 2 * ] test-walker ] unit-test

[ { 6 } ]
[ [ [ 3 swap continue-with ] callcc1 2 * ] test-walker ] unit-test

[ { } ]
[ [ [ ] [ ] recover ] test-walker ] unit-test

[ { 6 } ]
[ [ [ 3 throw ] [ 2 * ] recover ] test-walker ] unit-test

[ { T{ no-method f + nth } } ]
[ [ [ 0 \ + nth ] [ ] recover ] test-walker ] unit-test

[ { } ] [
    [ "a" "b" set "c" "d" set [ ] test-walker ] with-scope
] unit-test

: breakpoint-test ( -- x ) break 1 2 + ;

\ breakpoint-test don't-step-into

[ f ] [ \ breakpoint-test optimized? ] unit-test

[ { 3 } ] [ [ breakpoint-test ] test-walker ] unit-test

GENERIC: method-breakpoint-test ( x -- y )

TUPLE: method-breakpoint-tuple ;

M: method-breakpoint-tuple method-breakpoint-test break drop 1 2 + ;

\ method-breakpoint-test don't-step-into

[ { 3 } ]
[ [ T{ method-breakpoint-tuple } method-breakpoint-test ] test-walker ] unit-test

: case-breakpoint-test ( -- x )
    5 { [ break 1 + ] } case ;

\ case-breakpoint-test don't-step-into

[ { 6 } ] [ [ case-breakpoint-test ] test-walker ] unit-test

: call(-breakpoint-test ( -- x )
    [ break 1 ] call( -- x ) 2 + ;

\ call(-breakpoint-test don't-step-into

[ { 3 } ] [ [ call(-breakpoint-test ] test-walker ] unit-test
