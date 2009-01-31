USING: adsoda
kernel
math
accessors
sequences
    adsoda.solution2
    fry
    tools.test 
    arrays ;

IN: adsoda.tests



: s1 ( -- solid )
    <solid> 
    2 >>dimension
    "s1" >>name
    { 1 1 1 } >>color
    { 1 -1 -5 } cut-solid 
    { -1 -1 -21 } cut-solid 
    { -1 0 -12 } cut-solid 
    { 1 2 16 } cut-solid
;
: solid1 ( -- solid )
    <solid> 
    2 >>dimension
    "solid1" >>name
    { 1 -1 -5 } cut-solid 
    { -1 -1 -21 } cut-solid 
    { -1 0 -12 } cut-solid 
    { 1 2 16 } cut-solid
    ensure-adjacencies
    
;
: solid2 ( -- solid )
    <solid> 
    2 >>dimension
    "solid2" >>name
    { -1 1 -10 } cut-solid 
    { -1 -1 -28 } cut-solid 
    { 1 0 13 } cut-solid 
 !   { 1 2 16 } cut-solid
    ensure-adjacencies
    
;

: solid3 ( -- solid )
      <solid> 
    2 >>dimension
    "solid3" >>name
    { 1 1 1 } >>color
    { 1 0 16 } cut-solid 
    { -1 0 -36 } cut-solid 
    { 0 1 1 } cut-solid 
    { 0 -1  -17 } cut-solid 
 !   { 1 2 16 } cut-solid
    ensure-adjacencies
    

;

: solid4 ( -- solid )
      <solid> 
    2 >>dimension
    "solid4" >>name
    { 1 1 1 } >>color
    { 1 0 21 } cut-solid 
    { -1 0 -36 } cut-solid 
    { 0 1 1 } cut-solid 
    { 0 -1  -17 } cut-solid 
    ensure-adjacencies
    
;

: solid5 ( -- solid )
      <solid> 
    2 >>dimension
    "solid5" >>name
    { 1 1 1 } >>color
    { 1 0 6 } cut-solid 
    { -1 0 -17 } cut-solid 
    { 0 1 17 } cut-solid 
    { 0 -1  -19 } cut-solid 
    ensure-adjacencies
    
;

: solid7 ( -- solid )
      <solid> 
    2 >>dimension
    "solid7" >>name
    { 1 1 1 } >>color
    { 1 0 38 } cut-solid 
    { 1 -5 -66 } cut-solid 
    { -2 1 -75 } cut-solid
    ensure-adjacencies
    
;

: solid6s ( -- seq )
  solid3 clone solid2 clone subtract
;

: space1 ( -- space )
    <space>
        2 >>dimension
     !    solid3 suffix-solids
        solid1 suffix-solids
        solid2 suffix-solids
    !   solid6s [ suffix-solids ] each 
        solid4 suffix-solids
     !   solid5 suffix-solids
        solid7 suffix-solids
        { 1 1 1 } >>ambient-color
            <light>
        { -100 -100 } >>position
        { 0.2 0.7 0.1 } >>color
        suffix-lights
;

: space2 ( -- space )
    <space>
        4 >>dimension
       ! 4cube suffix-solids
        { 1 1 1 } >>ambient-color
            <light>
        { -100 -100 } >>position
        { 0.2 0.7 0.1 } >>color
        suffix-lights

       ;



! {
!        { 1 0 0 0 }
!        { 0 1 0 0 }
!        { 0 0 0.984807753012208 -0.1736481776669303 }
!        { 0 0 0.1736481776669303 0.984807753012208 }
!    }

! ------------------------------------------------------------
! constant+
[ { 1 2 5 } ] [ { 1 2 3 } 2 constant+ ] unit-test

! ------------------------------------------------------------
! translate
[ { 1 -1 0 } ] [ { 1 -1 -5 } { 3 -2 } translate ] unit-test

! ------------------------------------------------------------
! transform
[ { -1 -1 -5 21.0 } ] [ { -1 -1 -5 21 }
  { { 1 0 0 }
    { 0 1 0 }
    { 0 0 1 }
    } transform  
] unit-test

! ------------------------------------------------------------
! compare-nleft-to-identity-matrix
[ t ] [ 
    { 
        { 1 0 0 1232 } 
        { 0 1 0 0 321 } 
        { 0 0 1 0 } } 
        3 compare-nleft-to-identity-matrix 
]  unit-test

[ f ] [ 
    { { 1 0 0 } { 0 1 0 } { 0 0 0 } } 
    3 compare-nleft-to-identity-matrix 
] unit-test

[ f ] [ 
    { { 2 0 0 } { 0 1 0 } { 0 0 1 } } 
    3 compare-nleft-to-identity-matrix 
] unit-test
! ------------------------------------------------------------
[ t ] [ 
  { { 1 0 0 }
    { 0 1 0 }
    { 0 0 1 } } 3 valid-solution? 
] unit-test

[ f ] [ 
  { { 1 0 0 1 }
    { 0 0 0 1 }
    { 0 0 1 0 } } 3 valid-solution? 
] unit-test

[ f ] [ 
  { { 1 0 0 1 }
    { 0 0 0 1 } } 3 valid-solution? 
] unit-test

[ f ] [ 
  { { 1 0 0 1 }
    { 0 0 0 1 }
    { 0 0 1 0 } } 2 valid-solution? 
] unit-test

! ------------------------------------------------------------
[ 3 ] [ { 1 2 3 } last ] unit-test 

[ { 1 2 5 } ] [ { 1 2 3 } dup [ 2 + ] change-last ] unit-test 

! ------------------------------------------------------------
! position-point 
[ 0 ] [ 
    { 1 -1 -5 } { 2 7 } position-point 
] unit-test

! ------------------------------------------------------------

! transform
! TODO construire un exemple


! ------------------------------------------------------------
! slice-solid 

! ------------------------------------------------------------
! solve-equation 
! deux cas de tests, avec solution et sans solution

[ { 2 7 } ] 
[ { { 1 -1 -5 } { 1 2 16 } } intersect-hyperplanes ] 
unit-test

[ f ] 
[ { { 1 -1 -5 } { 1 2 16 } { -1 -1 -21 } } intersect-hyperplanes  ]
unit-test

[ f ] 
[ { { 1 0 -5 } { 1 0 16 }  } intersect-hyperplanes  ]
unit-test

! ------------------------------------------------------------
! point-inside-halfspace
[ t ] [ { 1 -1 -5 } { 0 0 }  point-inside-halfspace? ] 
unit-test
[ f ] [ { 1 -1 -5 } { 8 13 }  point-inside-halfspace? ] 
unit-test
[ t ] [ { 1 -1 -5 } { 8 13 }  point-inside-or-on-halfspace? ] 
unit-test


! ------------------------------
! order solid

[  1 ] [ 0 >pv solid1 solid2 order-solid ] unit-test
[ -1 ] [ 0 >pv solid2 solid1 order-solid ] unit-test
[  f ] [ 1 >pv solid1 solid2 order-solid ] unit-test
[  f ] [ 1 >pv solid2 solid1 order-solid ] unit-test


! clip-solid
[ { { 13 15 } { 15 13 } { 13 13 } } ]
    [ 0 >pv solid2 solid1 clip-solid first corners>> ] unit-test

solid1 corners>> '[ _ ]
    [ 0 >pv solid1 solid1 clip-solid first corners>> ] unit-test

solid1 corners>> '[ _ ]
    [ 0 >pv solid1 solid2 clip-solid first corners>> ] unit-test

solid1 corners>> '[ _ ]
    [ 1 >pv solid1 solid2 clip-solid first corners>> ] unit-test
solid2 corners>> '[ _ ]
    [ 1 >pv solid2 solid1 clip-solid first corners>> ] unit-test

!
[
    {
        { { 13 15 } { 15 13 } { 13 13 } }
        { { 16 17 } { 16 13 } { 36 17 } { 36 13 } }
        { { 16 1 } { 16 2 } { 36 1 } { 36 2 } }
    }
] [     0 >pv solid2 solid3  2array 
        solid1 (solids-silhouette-subtract) 
        [ corners>> ] map
  ] unit-test


[
{
    { { 8 13 } { 2 7 } { 12 9 } { 12 2 } }
    { { 13 15 } { 15 13 } { 13 13 } }
    { { 16 17 } { 16 15 } { 36 17 } { 36 15 } }
    { { 16 1 } { 16 2 } { 36 1 } { 36 2 } }
}
] [ 
    0 >pv  <space> solid1 suffix-solids 
        solid2 suffix-solids 
        solid3 suffix-solids
     remove-hidden-solids
    solids>> [ corners>> ] map
] unit-test

! { }
! { }
! <light> { 0.2 0.3 0.4 } >>color { 1 -1 1 } >>direction     suffix
! <light> { 0.4 0.3 0.1 } >>color { -1 -1 -1 } >>direction   suffix
! suffix 
! { 0.1 0.1 0.1 } suffix ! ambient color
! { 0.23 0.32 0.17 } suffix ! solid color
! solid3 faces>> first 

! enlight-projection
