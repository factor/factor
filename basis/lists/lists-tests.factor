! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test lists math kernel ;
IN: lists.tests

{ { 3 4 5 6 7 } } [
    { 1 2 3 4 5 } sequence>list [ 2 + ] lmap list>array
] unit-test

{ { 3 4 5 6 } } [
    T{ cons f 1       
        T{ cons f 2 
            T{ cons f 3
                T{ cons f 4
                +nil+ } } } } [ 2 + ] lmap>array
] unit-test

{ 10 } [
    T{ cons f 1       
        T{ cons f 2 
            T{ cons f 3
                T{ cons f 4
                +nil+ } } } } 0 [ + ] foldl
] unit-test
    
{ T{ cons f 2 T{ cons f 3 T{ cons f 4 T{ cons f 5 +nil+ } } } } } [
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

[ { 1 } { 2 } ] [ { 1 2 } sequence>list 1 lcut [ list>array ] bi@ ] unit-test
