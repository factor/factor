! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien destructors kernel math
memory.piles tools.test ;

{ 25 } [
    [
        100 <pile> &dispose
        [ 25 pile-alloc ] [ 50 pile-alloc ] bi
        swap [ alien-address ] bi@ -
    ] with-destructors
] unit-test

{ 32 } [
    [
        100 <pile> &dispose
        [ 25 pile-alloc ] [ 8 pile-align 50 pile-alloc ] bi
        swap [ alien-address ] bi@ -
    ] with-destructors
] unit-test

{ 75 } [
    [
        100 <pile> &dispose
        dup 25 pile-alloc drop
        dup 50 pile-alloc drop
        offset>>
    ] with-destructors
] unit-test

{ 100 } [
    [
        100 <pile> &dispose
        dup 25 pile-alloc drop
        dup 75 pile-alloc drop
        offset>>
    ] with-destructors
] unit-test

[
    [
        100 <pile> &dispose
        dup 25 pile-alloc drop
        dup 76 pile-alloc drop
    ] with-destructors
] [ not-enough-pile-space? ] must-fail-with
