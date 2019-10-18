! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences io io.streams.string math tools.test advice math.parser
parser namespaces multiline eval words assocs ;
IN: advice.tests

[
    [ ad-do-it ] must-fail
    
    : foo ( -- str ) "foo" ; 
    \ foo make-advised
 
    { "bar" "foo" } [
        [ "bar" ] "barify" \ foo advise-before
        foo
    ] unit-test
 
    { "bar" "foo" "baz" } [
        [ "baz" ] "bazify" \ foo advise-after
        foo
    ] unit-test
 
    { "foo" "baz" } [
        "barify" \ foo before remove-advice
        foo
    ] unit-test
 
    : bar ( a -- b ) 1 + ;
    \ bar make-advised

    { 11 } [
        [ 2 * ] "double" \ bar advise-before
        5 bar
    ] unit-test 

    { 11/3 } [
        [ 3 / ] "third" \ bar advise-after
        5 bar
    ] unit-test

    { -2 } [
        [ -1 * ad-do-it 3 + ] "frobnobicate" \ bar advise-around
        5 bar
    ] unit-test

    : add ( a b -- c ) + ;
    \ add make-advised

    { 10 } [
        [ [ 2 * ] bi@ ] "double-args" \ add advise-before
        2 3 add
    ] unit-test 

    { 21 } [
        [ 3 * ad-do-it 1- ] "around1" \ add advise-around
        2 3 add
    ] unit-test 

!     { 9 } [
!         [ [ 1- ] bi@ ad-do-it 2 / ] "around2" \ add advise-around
!         2 3 add
!     ] unit-test

!     { { "around1" "around2" } } [
!         \ add around word-prop keys
!     ] unit-test

    { 5 f } [
        \ add unadvise
        2 3 add \ add advised?
    ] unit-test

!     : quux ( a b -- c ) * ;

!     { f t 3+3/4 } [
!         <" USING: advice kernel math ;
!            IN: advice.tests
!            \ quux advised?
!            ADVISE: quux halve before [ 2 / ] bi@ ;
!            \ quux advised? 
!            3 5 quux"> eval
!     ] unit-test

!     { 3+3/4 "1+1/2 2+1/2 3+3/4" } [
!         <" USING: advice kernel math math.parser io io.streams.string ;
!            IN: advice.tests
!            ADVISE: quux log around
!            2dup [ number>string write " " write ] bi@
!            ad-do-it 
!            dup number>string write ;
!            [ 3 5 quux ] with-string-writer"> eval
!     ] unit-test 
 
] with-scope
