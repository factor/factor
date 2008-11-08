! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences assocs tools.test linked-assocs ;
IN: linked-assocs.test

{ { 1 2 3 } } [
    <linked-hash> 1 "b" pick set-at
                  2 "c" pick set-at
                  3 "a" pick set-at
    values
] unit-test

{ 2 t } [
    <linked-hash> 1 "b" pick set-at
                  2 "c" pick set-at
                  3 "a" pick set-at
    "c" swap at*
] unit-test

{ { 2 3 4 } { "c" "a" "d" } } [
    <linked-hash> 1 "a" pick set-at
                  2 "c" pick set-at
                  3 "a" pick set-at
                  4 "d" pick set-at
    [ values ] [ keys ] bi 
] unit-test 