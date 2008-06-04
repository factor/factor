! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test lists math ;

IN: lists.tests

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
                +nil+ } } } } 0 [ + ] lreduce
] unit-test
    
{ T{ cons f
      1
      T{ cons f
          2
          T{ cons f
              T{ cons f
                  3
                  T{ cons f
                      4
                      T{ cons f
                          T{ cons f 5 +nil+ }
                          +nil+ } } }
          +nil+ } } }
} [
    { 1 2 { 3 4 { 5 } } } seq>cons
] unit-test
    
{ { 1 2 { 3 4 { 5 } } } } [
  { 1 2 { 3 4 { 5 } } } seq>cons cons>seq  
] unit-test
    
{ T{ cons f 2 T{ cons f 3 T{ cons f 4 T{ cons f 5 +nil+ } } } } } [
    { 1 2 3 4 } seq>cons [ 1+ ] lmap
] unit-test
    
! { { 3 4 { 5 6 { 7 } } } } [
!   { 1 2 { 3 4 { 5 } } } seq>cons [ 2 + ] traverse cons>seq
! ] unit-test