USING: arrays kernel math math.constants math.functions math.matrices math.vectors math.quaternions random sequences ;
IN: jamshred.oint

! An oint is a point with three linearly independent unit vectors
! given relative to that point. In jamshred a player's location and
! direction are given by the player's oint. Similarly, a tunnel
! segment's location and orientation are given by an oint.

TUPLE: oint location forward up left ;

: <oint> ( location forward up left -- oint )
    oint construct-boa ;

! : x-rotation ( theta -- matrix )
!     #! construct this matrix:
!     #! { { 1           0          0 }
!     #!   { 0  cos(theta) sin(theta) }
!     #!   { 0 -sin(theta) cos(theta) } }
!     dup sin neg swap cos 2dup 0 -rot 3array >r
!     swap neg 0 -rot 3array >r
!     { 1 0 0 } r> r> 3array ;
! 
! : y-rotation ( theta -- matrix )
!     #! costruct this matrix:
!     #! { { cos(theta) 0 -sin(theta) }
!     #!   {          0 1           0 }
!     #!   { sin(theta) 0  cos(theta) } }
!     dup sin swap cos 2dup
!     0 swap 3array >r
!     { 0 1 0 } >r
!     0 rot neg 3array r> r> 3array ;

: apply-to-oint ( oint quot -- )
    #! apply quot to each of forward, up, and left, storing the results
    over oint-forward over call pick set-oint-forward
    over oint-up over call pick set-oint-up
    over oint-left swap call swap set-oint-left ;

: rotation-quaternion ( theta axis -- quaternion )
    swap 2 / dup cos swap sin rot n*v first3 rect> >r rect> r> 2array ;

: rotate-oint ( oint theta axis -- )
    rotation-quaternion dup qrecip
    [ rot v>q swap q* q* q>v ] curry curry apply-to-oint ;

: left-pivot ( oint theta -- )
    over oint-left rotate-oint ;

: up-pivot ( oint theta -- )
    over oint-up rotate-oint ;

: random-float+- ( n -- m )
    #! find a random float between -n/2 and n/2
    dup 10000 * >fixnum random 10000 / swap 2 / - ;

: random-turn ( oint theta -- )
    2 / 2dup random-float+- left-pivot random-float+- up-pivot ;

: go-forward ( distance oint -- )
    tuck oint-forward n*v over oint-location v+ swap set-oint-location ;

: distance ( oint oint -- distance )
    oint-location swap oint-location v- norm ;
