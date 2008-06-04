! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test lists math ;

IN: lists.tests

{ { 3 4 5 6 } } [
    T{ cons f 1       
        T{ cons f 2 
            T{ cons f 3
                T{ cons f 4
                nil } } } } [ 2 + ] lmap
] unit-test

{ 10 } [
    T{ cons f 1       
        T{ cons f 2 
            T{ cons f 3
                T{ cons f 4
                nil } } } } 0 [ + ] lreduce
] unit-test
    
T{
    cons
    f
    1
    T{
        cons
        f
        2
        T{
            cons
            f
            T{ cons f 3 T{ cons f 4 T{ cons f 5 nil } } }
            T{ cons f f f }
        } } } [
    { 1 2 { 3 4 { 5 } } } seq>cons
] unit-test
    
{ { 1 2 { 3 4 { 5 } } } } [
  { 1 2 { 3 4 { 5 } } } seq>cons cons>seq  
] unit-test