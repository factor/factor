usereg

[ (-1,-1,0) (1,-1,0)
  (1,1,0) (-1,1,0) ] !poly

:poly 1 poly2doubleface
dup edgemate exch
1 1 extrude-simple !f0 !f1

:poly { 0.5 mul } map reverse
5 poly2doubleface
dup edgemate exch
-1 1 extrude-simple
!r0 !r1

:r0 :f0 killFmakeRH
:r1 :f1 killFmakeRH
