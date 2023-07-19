! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel linked-assocs math sequences
tools.test ;

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
    "c" ?of
] unit-test

{ { 2 3 4 } { "c" "a" "d" } 3 } [
    <linked-hash> 1 "a" pick set-at
                  2 "c" pick set-at
                  3 "a" pick set-at
                  4 "d" pick set-at
    [ values ] [ keys ] [ assoc-size ] tri
] unit-test

{ f 1 } [
    <linked-hash> 1 "c" pick set-at
                  2 "b" pick set-at
    "c" over delete-at
    "c" over at swap assoc-size
] unit-test

{ { } 0 } [
    <linked-hash> 1 "a" pick set-at
                  2 "c" pick set-at
                  3 "a" pick set-at
                  4 "d" pick set-at
    dup clear-assoc [ keys ] [ assoc-size ] bi
] unit-test

{ { } { 1 2 3 } } [
    <linked-hash> dup clone
    1 "c" pick set-at
    2 "q" pick set-at
    3 "a" pick set-at
    [ values ] bi@
] unit-test

{ 9 } [
    <linked-hash>
    { [ 3 * ] [ 1 - ] }          "first"   pick set-at
    { [ [ 1 - ] bi@ ] [ 2 / ] }  "second"  pick set-at
    4 6 pick values [ first call ] each
    + swap values <reversed> [ second call ] each
] unit-test

{ V{ { "az" 1 } { "by" 2 } { "cx" 3 } } } [
    <linked-hash>
    1 "az" pick set-at
    2 "by" pick set-at
    3 "cx" pick set-at
    >alist
] unit-test

{ t V{ { 1 20 } { 3 40 } { 5 60 } } } [
    { { 1 2 } { 3 4 } { 5 6 } } >linked-hash
    [ 10 * ] assoc-map [ linked-assoc? ] [ >alist ] bi
] unit-test

{ V{ { 1 2 } { 3 4 } { 5 6 } } } [
    { { 1 2 } { 3 4 } { 5 6 } }
    { } <linked-assoc> assoc-like >alist
] unit-test

{ t } [
    { { "a" "b" } { "c" "d" } }
    [ >linked-hash ] [ >linked-hash ] bi =
] unit-test

{ LH{ } } [ 0 LH{ { 1 2 } { 3 4 } } new-assoc ] unit-test
