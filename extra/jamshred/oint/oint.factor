! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel locals math math.constants math.functions math.matrices math.vectors math.quaternions random sequences ;
IN: jamshred.oint

! An oint is a point with three linearly independent unit vectors
! given relative to that point. In jamshred a player's location and
! direction are given by the player's oint. Similarly, a tunnel
! segment's location and orientation are given by an oint.

TUPLE: oint location forward up left ;
C: <oint> oint

: rotation-quaternion ( theta axis -- quaternion )
    swap 2 / dup cos swap sin rot n*v first3 rect> [ rect> ] dip 2array ;

: rotate-vector ( q qrecip v -- v )
    v>q swap q* q* q>v ;

: rotate-oint ( oint theta axis -- )
    rotation-quaternion dup qrecip pick
    [ forward>> rotate-vector >>forward ]
    [ up>> rotate-vector >>up ]
    [ left>> rotate-vector >>left ] 3tri drop ;

: left-pivot ( oint theta -- )
    over left>> rotate-oint ;

: up-pivot ( oint theta -- )
    over up>> rotate-oint ;

: forward-pivot ( oint theta -- )
    over forward>> rotate-oint ;

: random-float+- ( n -- m )
    #! find a random float between -n/2 and n/2
    dup 10000 * >fixnum random 10000 / swap 2 / - ;

: random-turn ( oint theta -- )
    2 / 2dup random-float+- left-pivot random-float+- up-pivot ;

: location+ ( v oint -- )
    [ location>> v+ ] [ (>>location) ] bi ;

: go-forward ( distance oint -- )
    [ forward>> n*v ] [ location+ ] bi ;

: distance-vector ( oint oint -- vector )
    [ location>> ] bi@ swap v- ;

: distance ( oint oint -- distance )
    distance-vector norm ;

: scalar-projection ( v1 v2 -- n )
    #! the scalar projection of v1 onto v2
    tuck v. swap norm / ;

: proj-perp ( u v -- w )
    dupd proj v- ;

: perpendicular-distance ( oint oint -- distance )
    tuck distance-vector swap 2dup left>> scalar-projection abs
    -rot up>> scalar-projection abs + ;

:: reflect ( v n -- v' )
    #! bounce v on a surface with normal n
    v v n v. n n v. / 2 * n n*v v- ;

: half-way ( p1 p2 -- p3 )
    over v- 2 v/n v+ ;

: half-way-between-oints ( o1 o2 -- p )
    [ location>> ] bi@ half-way ;
