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
        { 1 [ [ dup ] ] }
        { 2 [ [ over ] ] }
        { 3 [ [ pick ] ] }
        [ 
            [ 
                1 - dup 
                [ \ >r , ] times 
                \ dup , 
                [ [ r> swap ] % ] times 
            ] [ ] make 
        ]
    } case ;

: npick ( quot n -- a ) [npick] call ;  
\ npick 1 [ [npick] ] define-transform
  
: [ndup] ( n -- quot )
    {
        { 1 [ [ dup ] ] }
        { 2 [ [ 2dup ] ] }
        { 3 [ [ 3dup ] ] }
        [ [ dup [ dup , \ npick , ] times drop ] [ ] make ]
    } case ;

: ndup ( n -- ) [ndup] call ;
\ ndup 1 [ [ndup] ] define-transform

: [nrot] ( n -- quot )
    {
        { 1 [ [ ] ] }
        { 2 [ [ swap ] ] }
        { 3 [ [ rot ] ] }
        [ 
            [
                \ >r ,
                1- [nrot] %
                [ r> swap ] % 
            ] [ ] make 
        ]
    } case ;

: nrot ( n -- ) [nrot] call ;
\ nrot 1 [ [nrot] ] define-transform

: [-nrot] ( n -- quot )
    {
        { 1 [ [ ] ] }
        { 2 [ [ swap ] ] }
        { 3 [ [ -rot ] ] }
        [ 
            [
                [ swap >r ] %
                1- [-nrot] %
                \ r> , 
            ] [ ] make 
        ]
    } case ;

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
        { 1 [ [ nip ] ] }
        { 2 [ [ 2nip ] ] }
        [ 
            [ 
                1 - [nnip] %
                \ nip ,
            ] [ ] make 
        ]
    } case ;

: nnip ( quot n -- ) [nnip] call ; 
\ nnip 1 [ [nnip] ] define-transform

: [ndrop] ( n -- quot )
    {
        { 1 [ [ drop ] ] }
        { 2 [ [ 2drop ] ] }
        { 3 [ [ 3drop ] ] }
        [ 
            [ 
                1 - [ndrop] %
                \ drop ,
            ] [ ] make 
        ]
    } case ;

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

: [ntuck] ( n -- quot )
    {
        { 1 [ [ tuck ] ] }
        [
            [
                \ dup ,
                2 + ,
                \ -nrot ,
            ] [ ] make
        ]
    } case ;

: ntuck ( x y -- y... x y ) [ntuck] call ;
\ ntuck 1 [ [ntuck] ] define-transform

: [napply] ( n -- quot )
    [
        dup 1-
        [ - [ 1- , \ ntuck , ] keep , \ nslip , ] each-with
        \ call ,
    ] [ ] make ;

: napply ( quot n -- ) [napply] call ;
\ napply 1 [ [napply] ] define-transform

