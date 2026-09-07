USING: tools.walker io io.streams.string kernel math
math.private namespaces prettyprint sequences tools.test
continuations math.parser threads arrays tools.walker.debug
generic.single sequences.private kernel.private
tools.continuations accessors words combinators fry locals
vectors prettyprint.private ;
IN: tools.walker.tests

{ { } } [
    [ ] test-walker
] unit-test

{ { 1 } } [
    [ 1 ] test-walker
] unit-test

{ { 1 2 3 } } [
    [ 1 2 3 ] test-walker
] unit-test

{ { "Yo" 2 } } [
    [ 2 [ "Yo" ] dip ] test-walker
] unit-test

{ { "Yo" 2 3 } } [
    [ 2 [ "Yo" ] dip 3 ] test-walker
] unit-test

{ { 2 } } [
    [ t [ 2 ] [ "hi" ] if ] test-walker
] unit-test

{ { "hi" } } [
    [ f [ 2 ] [ "hi" ] if ] test-walker
] unit-test

{ { 4 } } [
    [ 2 2 fixnum+ ] test-walker
] unit-test

: foo ( -- x ) 2 2 fixnum+ ;

{ { 8 } } [
    [ foo 4 fixnum+ ] test-walker
] unit-test

{ { C{ 1 1.5 } { } C{ 1 1.5 } { } } } [
    [ C{ 1 1.5 } { } 2dup ] test-walker
] unit-test

{ { t } } [
    [ 5 5 number= ] test-walker
] unit-test

{ { f } } [
    [ 5 6 number= ] test-walker
] unit-test

{ { 0 } } [
    [ 0 { array-capacity } declare ] test-walker
] unit-test

{ { f } } [
    [ "XYZ" "XYZ" mismatch ] test-walker
] unit-test

{ { t } } [
    [ "XYZ" "XYZ" sequence= ] test-walker
] unit-test

{ { t } } [
    [ "XYZ" "XYZ" = ] test-walker
] unit-test

{ { f } } [
    [ "XYZ" "XuZ" = ] test-walker
] unit-test

{ { 4 } } [
    [ 2 2 + ] test-walker
] unit-test

{ { 3 } } [
    [ [ 3 "x" set "x" get ] with-scope ] test-walker
] unit-test

{ { "hi\n" } } [
    [ [ "hi" print ] with-string-writer ] test-walker
] unit-test

{ { "4\n" } } [
    [ [ 2 2 + number>string print ] with-string-writer ] test-walker
] unit-test

{ { 1 2 3 } } [
    [ { 1 2 3 } set-datastack ] test-walker
] unit-test

{ { 6 } }
[ [ 3 [ nip continue ] callcc0 2 * ] test-walker ] unit-test

{ { 6 } }
[ [ [ 3 swap continue-with ] callcc1 2 * ] test-walker ] unit-test

{ { } }
[ [ [ ] [ ] recover ] test-walker ] unit-test

{ { 6 } }
[ [ [ 3 throw ] [ 2 * ] recover ] test-walker ] unit-test

{ { T{ no-method f + nth } } }
[ [ [ 0 \ + nth ] [ ] recover ] test-walker ] unit-test

{ { } } [
    [ "a" "b" set "c" "d" set [ ] test-walker ] with-scope
] unit-test

: breakpoint-test ( -- x ) break 1 2 + ;

\ breakpoint-test don't-step-into

{ f } [ \ breakpoint-test word-optimized? ] unit-test

{ { 3 } } [ [ breakpoint-test ] test-walker ] unit-test

GENERIC: method-breakpoint-test ( x -- y )

TUPLE: method-breakpoint-tuple ;

M: method-breakpoint-tuple method-breakpoint-test break drop 1 2 + ;

\ method-breakpoint-test don't-step-into

{ { 3 } }
[ [ T{ method-breakpoint-tuple } method-breakpoint-test ] test-walker ] unit-test

: case-breakpoint-test ( -- x )
    5 { [ break 1 + ] } case ;

\ case-breakpoint-test don't-step-into

{ { 6 } } [ [ case-breakpoint-test ] test-walker ] unit-test

: call(-breakpoint-test ( -- x )
    [ break 1 ] call( -- x ) 2 + ;

\ call(-breakpoint-test don't-step-into

{ { 3 } } [ [ call(-breakpoint-test ] test-walker ] unit-test

! #758: stepping over construction must preserve the source form, and
! stepping into the constructed quotation must still reach its body.
: fry-walker-test ( -- n ) 3 '[ _ 1 + ] call ;

:: trace-fry-walker ( quot -- data stops )
    V{ } clone :> stops
    break-hook get :> hook
    [ dup stops push hook call ] break-hook
    [ quot test-walker ] with-variable stops ;

:: fry-walker-stops ( -- before after )
    [ fry-walker-test ] trace-fry-walker nip :> stops
    stops [ continuation-current fry-word? ] find drop :> i
    i stops nth i 1 + stops nth ;

{ { 4 } } [ [ fry-walker-test ] test-walker ] unit-test

{ "'[ _ 1 + ]" } [
    fry-walker-stops drop continuation-current unparse
] unit-test

{ t { [ break 3 1 + ] } } [
    fry-walker-stops nip
    [ continuation-current \ call eq? ] [ data>> ] bi
] unit-test

: fry-stop-display ( continuation -- string )
    call>> [ innermost-frame-executing ] [ innermost-frame-scan ] bi
    remove-breakpoints unparse ;

{ "[ 3 => '[ _ 1 + ] call ]" "[ 3 '[ _ 1 + ] => call ]" } [
    fry-walker-stops [ fry-stop-display ] bi@
] unit-test

{ t } [
    [ fry-walker-test ] trace-fry-walker nip
    [ continuation-current \ + eq? ] any?
] unit-test

{ { 17 } } [
    [ 5 [| outer | 10 '[ 2 [| a | a _ + outer + ] ] call call ] call ]
    test-walker
] unit-test

{ { 1 2 } } [ [ 1 '[ _ 2 '[ _ ] call ] call ] test-walker ] unit-test

! Into on fry behaves like Into on a quotation literal: construct and
! arm it, then stop inside its body when the program calls it.
:: walk-fry-commands ( quot commands -- data stops )
    V{ } clone :> stops
    [
        dup stops push
        stops length 1 - commands ?nth
        [ call( continuation -- continuation' ) ] when*
    ] break-hook [
        { } [ quot add-breakpoint call ] with-datastack
    ] with-variable stops ;

{ { [ 1 34 3 5 + + ] } } [
    [ 3 '[ 1 34 _ 5 + + ] ]
    { [ continuation-step ] [ continuation-step ] }
    walk-fry-commands drop
] unit-test

{ { [ break 1 34 3 5 + + ] } } [
    [ 3 '[ 1 34 _ 5 + + ] ]
    { [ continuation-step ] [ continuation-step-into ] }
    walk-fry-commands drop
] unit-test

{ { 1 42 } { { } { 1 } { 1 34 } { 1 34 3 } { 1 34 3 5 } { 1 34 8 } } } [
    [ 3 '[ 1 34 _ 5 + + ] call ]
    {
        [ continuation-step ] [ continuation-step-into ]
        [ continuation-step ] [ continuation-step ]
        [ continuation-step ] [ continuation-step ]
        [ continuation-step ] [ continuation-step ]
        [ continuation-step ]
    } walk-fry-commands
    3 9 rot subseq [ data>> ] map >array
] unit-test

! Walking a cold macro must not cache an armed fry for later callers.
MACRO: fry-walker-macro ( n -- quot ) '[ _ ] ;

{ { 42 } } [ [ 42 fry-walker-macro ] test-walker ] unit-test

{ 42 } [
    [ "Breakpoint escaped the walker" throw ] break-hook
    [ 42 fry-walker-macro ] with-variable
] unit-test
