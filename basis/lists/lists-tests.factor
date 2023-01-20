! Copyright (C) 2008 James Cash
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test lists math kernel ;

{ { 3 4 5 6 7 } } [
    { 1 2 3 4 5 } sequence>list [ 2 + ] lmap list>array
] unit-test

{ 2 { 3 4 5 6 7 } } [
    2 { 1 2 3 4 5 } sequence>list [ dupd + ] lmap list>array
] unit-test

{ { 3 4 5 6 } } [
    T{ cons-state f 1
        T{ cons-state f 2
            T{ cons-state f 3
                T{ cons-state f 4
                +nil+ } } } } [ 2 + ] lmap>array
] unit-test

{ 10 } [
    T{ cons-state f 1
        T{ cons-state f 2
            T{ cons-state f 3
                T{ cons-state f 4
                +nil+ } } } } 0 [ + ] foldl
] unit-test

{ T{ cons-state f 2 T{ cons-state f 3 T{ cons-state f 4 T{ cons-state f 5 +nil+ } } } } } [
    { 1 2 3 4 } sequence>list [ 1 + ] lmap
] unit-test

{ 15 } [
    { 1 2 3 4 5 } sequence>list 0 [ + ] foldr
] unit-test

{ { 5 4 3 2 1 } } [
    { 1 2 3 4 5 } sequence>list lreverse list>array
] unit-test

{ 5 } [
    { 1 2 3 4 5 } sequence>list llength
] unit-test

{ { 1 2 3 4 5 6 } } [
    { 1 2 3 } sequence>list { 4 5 6 } sequence>list lappend list>array
] unit-test

{ { 1 } { 2 } } [ { 1 2 } sequence>list 1 lcut [ list>array ] bi@ ] unit-test

{ { { 1 } { { 2 } } } } [
    1 nil cons 2 nil cons nil cons nil cons cons deeplist>array
] unit-test
