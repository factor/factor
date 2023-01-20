! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.vectors sequences ;
IN: rosetta-code.raycasting


! https://rosettacode.org/wiki/Ray-casting_algorithm

! Given a point and a polygon, check if the point is inside or
! outside the polygon using the ray-casting algorithm.

! A pseudocode can be simply:

! count ← 0
! foreach side in polygon:
!   if ray_intersects_segment(P,side) then
!     count ← count + 1
! if is_odd(count) then
!   return inside
! else
!   return outside

! Where the function ray_intersects_segment return true if the
! horizontal ray starting from the point P intersects the side
! (segment), false otherwise.

! An intuitive explanation of why it works is that every time we
! cross a border, we change "country" (inside-outside, or
! outside-inside), but the last "country" we land on is surely
! outside (since the inside of the polygon is finite, while the
! ray continues towards infinity). So, if we crossed an odd number
! of borders we was surely inside, otherwise we was outside; we
! can follow the ray backward to see it better: starting from
! outside, only an odd number of crossing can give an inside:
! outside-inside, outside-inside-outside-inside, and so on (the -
! represents the crossing of a border).

! So the main part of the algorithm is how we determine if a ray
! intersects a segment. The following text explain one of the
! possible ways.

! Looking at the image on the right, we can easily be convinced
! of the fact that rays starting from points in the hatched area
! (like P1 and P2) surely do not intersect the segment AB. We also
! can easily see that rays starting from points in the greenish
! area surely intersect the segment AB (like point P3).

! So the problematic points are those inside the white area (the
! box delimited by the points A and B), like P4.

! Let us take into account a segment AB (the point A having y
! coordinate always smaller than B's y coordinate, i.e. point A is
! always below point B) and a point P. Let us use the cumbersome
! notation PAX to denote the angle between segment AP and AX,
! where X is always a point on the horizontal line passing by A
! with x coordinate bigger than the maximum between the x
! coordinate of A and the x coordinate of B. As explained
! graphically by the figures on the right, if PAX is greater than
! the angle BAX, then the ray starting from P intersects the
! segment AB. (In the images, the ray starting from PA does not
! intersect the segment, while the ray starting from PB in the
! second picture, intersects the segment).

! Points on the boundary or "on" a vertex are someway special
! and through this approach we do not obtain coherent results.
! They could be treated apart, but it is not necessary to do so.

! An algorithm for the previous speech could be (if P is a
! point, Px is its x coordinate):

! ray_intersects_segment:
!    P : the point from which the ray starts
!    A : the end-point of the segment with the smallest y coordinate
!        (A must be "below" B)
!    B : the end-point of the segment with the greatest y coordinate
!        (B must be "above" A)
! if Py = Ay or Py = By then
!   Py ← Py + ε
! end if
! if Py < Ay or Py > By then
!   return false
! else if Px > max(Ax, Bx) then
!   return false
! else
!   if Px < min(Ax, Bx) then
!     return true
!   else
!     if Ax ≠ Bx then
!       m_red ← (By - Ay)/(Bx - Ax)
!     else
!       m_red ← ∞
!     end if
!     if Ax ≠ Px then
!       m_blue ← (Py - Ay)/(Px - Ax)
!     else
!       m_blue ← ∞
!     end if
!     if m_blue ≥ m_red then
!       return true
!     else
!       return false
!     end if
!   end if
! end if

! (To avoid the "ray on vertex" problem, the point is moved
! upward of a small quantity ε)

: between ( a b x -- ? ) [ last ] tri@ [ < ] curry bi@ xor ;

: lincomb ( a b x -- w )
    3dup [ last ] tri@
    [ - ] curry bi@
    nipd
    neg 2dup + [ / ] curry bi@
    [ [ v*n ] curry ] bi@ bi*  v+ ;

: leftof ( a b x -- ? ) dup [ lincomb ] dip [ first ] bi@ > ;

: ray ( a b x -- ? ) [ between ] [ leftof ] 3bi and ;

: raycast ( poly x -- ? )
    [ dup first suffix [ rest-slice ] [ but-last-slice ] bi ] dip
    [ ray ] curry 2map
    f [ xor ] reduce ;
