! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: generalizations kernel shuffle ;
IN: shuffle.extras

: 6roll ( a b c d e f -- b c d e f a ) [ roll ] 2dip rot ; inline

: 7roll ( a b c d e f g -- b c d e f g a ) [ roll ] 3dip roll ; inline

: 8roll ( a b c d e f g h -- b c d e f g h a ) [ roll ] 4dip 5roll ; inline

: keep-1up ( quot -- quot ) keep swap ; inline
: keep-2up ( quot -- quot ) keep rot rot ; inline
: keep-3up ( quot -- quot ) keep roll roll roll ; inline

: 2keep-1up ( quot -- quot ) 2keep rot ; inline
: 2keep-2up ( quot -- quot ) 2keep roll roll ; inline
: 2keep-3up ( quot -- quot ) 2keep 5 nrot 5 nrot 5 nrot ; inline

: 3keep-1up ( quot -- quot ) 3keep roll ; inline
: 3keep-2up ( quot -- quot ) 3keep 5 nrot 5 nrot ; inline
: 3keep-3up ( quot -- quot ) 3keep 6 nrot 6 nrot 6 nrot ; inline

! d is dummy, o is object to save notation space
: dip-1up  ( ..a d quot: ( ..a -- ..b o d ) -- ..b d o )
    dip swap ; inline
: dip-2up  ( ..a d quot: ( ..a -- ..b o1 o2 d ) -- ..b d o1 o2 )
    dip rot rot ; inline

: 2dip-1up ( ..a d1 d2 quot: ( ..a -- ..b o d1 d2 ) -- ..b d1 d2 o )
    2dip rot ; inline
: 2dip-2up ( ..a d1 d2 quot: ( ..a -- ..b o1 o2 d1 d2 ) -- ..b d1 d2 o1 o2 )
    2dip roll roll ; inline

: 3dip-1up ( ..a d1 d2 d3 quot: ( ..a -- ..b o d1 d2 d3 ) -- ..b d1 d2 d3 o )
    3dip roll ; inline
: 3dip-2up ( ..a d1 d2 d3 quot: ( ..a -- ..b o1 o2 d1 d2 d3 ) -- ..b d1 d2 d3 o1 o2 )
    3dip 5roll 5roll ; inline
: 3dip-3up ( ..a d1 d2 d3 quot: ( ..a -- ..b o1 o2 o3 d1 d2 d3 ) -- ..b d1 d2 d3 o1 o2 o3 )
    3dip 6roll 6roll 6roll ; inline


: 2craft-1up ( ..a quot1: ( ..a -- ..b o1 ) quot2: ( ..b -- ..c o2 ) -- ..c o1 o2 )
    [ call ] dip [ dip-1up ] call ; inline

: 3craft-1up ( ..a quot1: ( ..a -- ..b o1 ) quot2: ( ..b -- ..c o2 ) quot3: ( ..c -- ..d o3 ) -- ..d o1 o2 o3 )
    [ call ] 2dip [ dip-1up ] dip [ 2dip-1up ] call ; inline

: 4craft-1up ( ..a quot1: ( ..a -- ..b o1 ) quot2: ( ..b -- ..c o2 ) quot3: ( ..c -- ..d o3 ) quot4: ( ..d -- ..e o4 ) -- ..e o1 o2 o3 o4 )
    [ call ] 3dip [ dip-1up ] 2dip [ 2dip-1up ] dip [ 3dip-1up ] call ; inline

: 3and ( a b c -- ? ) and and ; inline
: 4and ( a b c d -- ? ) and and and ; inline

: 3or ( a b c -- ? ) or or ; inline
: 4or ( a b c d -- ? ) or or or ; inline
