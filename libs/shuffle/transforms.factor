! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel sequences namespaces math inference ;
IN: shuffle

: [ndip] ( n -- quot )
    [ dup [ [ swap >r ] % ] times \ call , [ \ r> , ] times ] [ ] make ;

: ndip ( quot n -- ) [ndip] call ; 
\ ndip 1 [ [ndip] ] define-transform

: [npick] ( n -- quot )
    {
        { [ dup 1 = ] [ drop [ dup ] ] }
        { [ dup 2 = ] [ drop [ over ] ] }
        { [ dup 3 = ] [ drop [ pick ] ] }
        { [ t ] [ 
            [ 
                1 - dup 
                [ \ >r , ] times 
                \ dup , 
                [ [ r> swap ] % ] times 
            ] [ ] make 
          ] }
    } cond ;

: npick ( quot n -- a ) [npick] call ;  
\ npick 1 [ [npick] ] define-transform
  
: [ndup] ( n -- quot )
    {
        { [ dup 1 = ] [ drop [ dup ] ] }
        { [ dup 2 = ] [ drop [ 2dup ] ] }
        { [ dup 3 = ] [ drop [ 3dup ] ] }
        { [ t ] [ [ dup [ dup , \ npick , ] times drop ] [ ] make ] }
    } cond ;

: ndup ( n -- ) [ndup] call ;
\ ndup 1 [ [ndup] ] define-transform

: [nrot] ( n -- quot )
    {
        { [ dup 1 = ] [ drop [ ] ] }
        { [ dup 2 = ] [ drop [ swap ] ] }
        { [ dup 3 = ] [ drop [ rot ] ] }
        { [ t ] [ 
              [
                  \ >r ,
                  1- [nrot] %
                  [ r> swap ] % 
              ] [ ] make 
          ] } 
    } cond ;

: nrot ( n -- ) [nrot] call ;
\ nrot 1 [ [nrot] ] define-transform

: [-nrot] ( n -- quot )
    {
        { [ dup 1 = ] [ drop [ ] ] }
        { [ dup 2 = ] [ drop [ swap ] ] }
        { [ dup 3 = ] [ drop [ -rot ] ] }
        { [ t ] [ 
              [
                  [ swap >r ] %
                  1- [-nrot] %
                  \ r> , 
              ] [ ] make 
          ] } 
    } cond ;

: -nrot ( n -- ) [-nrot] call ;
\ -nrot 1 [ [-nrot] ] define-transform

: [nslip] ( n -- quot )
  [
    dup [ \ >r , ] times
    \ call ,
    [ \ r> , ] times
  ] [ ] make ;

: nslip ( quot n -- ) [nslip] call ; 
\ nslip 1 [ [nslip] ] define-transform

: [nkeep] ( n -- quot )
    [ 
        \ >r ,
        dup , \ ndup ,
        \ r> ,
        dup 1+ , \ -nrot , 
        , \ nslip ,
    ] [ ] make ;

: nkeep ( quot n -- ) [nkeep] call ; 
\ nkeep 1 [ [nkeep] ] define-transform

: [nnip] ( n -- quot )
    {
        { [ dup 1 = ] [ drop [ nip ] ] }
        { [ dup 2 = ] [ drop [ 2nip ] ] }
        { [ t ] [ 
            [ 
                1 - [nnip] %
                \ nip ,
            ] [ ] make 
          ] }
    } cond ;

: nnip ( quot n -- ) [nnip] call ; 
\ nnip 1 [ [nnip] ] define-transform

: [ndrop] ( n -- quot )
    {
        { [ dup 1 = ] [ drop [ drop ] ] }
        { [ dup 2 = ] [ drop [ 2drop ] ] }
        { [ dup 3 = ] [ drop [ 3drop ] ] }
        { [ t ] [ 
            [ 
                1 - [ndrop] %
                \ drop ,
            ] [ ] make 
          ] }
    } cond ;

: ndrop ( quot n -- ) [ndrop] call ; 
\ ndrop 1 [ [ndrop] ] define-transform

: [nwith] ( n -- quot )
    [ 
        dup 2 + , \ -nrot ,
        [ 
            \ >r , 
            dup 1 + , \ nrot ,
            \ r> , 
            \ call ,
        ] [ ] make ,
        1 + , \ nkeep ,
    ] [ ] make ;

: nwith ( quot n -- ) [nwith] call ; 
\ nwith 1 [ [nwith] ] define-transform

: [map-withn] ( n -- quot )
    [
        \ swap ,
        [
            dup , \ nwith , 
            dup 2 + , \ nrot ,            
        ] [ ] make ,
        \ map ,
        1 + , \ nnip ,        
    ] [ ] make ;

: map-withn ( seq quot n -- result ) [map-withn] call ; 
\ map-withn 1 [ [map-withn] ] define-transform

: [each-withn] ( n -- quot )
    [
        \ swap ,
        [
            dup , \ nwith , 
        ] [ ] make ,
        \ each ,
        1 + , \ ndrop ,        
    ] [ ] make ;

: each-withn ( seq quot n -- ) [each-withn] call ; 
\ each-withn 1 [ [each-withn] ] define-transform