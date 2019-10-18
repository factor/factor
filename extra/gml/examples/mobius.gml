usereg

0.0 !alpha
0.1 !thickness

:alpha sin :alpha cos 0 vector3 !p

:p :p (0,0,1) cross :alpha 0.5 mul rot_vec
0.3 mul !q

(0,0,1) :p (0,0,1) cross :alpha 0.5 mul rot_vec
:thickness mul !r

[ :p :q add :r add
  :p :q sub :r add
  :p :q sub :r sub
  :p :q add :r sub
] 4 poly2doubleface dup !e0

10.0 10.0 360.0 { !alpha

:alpha sin :alpha cos 0 vector3 !p

:p :p (0,0,1) cross :alpha 0.5 mul rot_vec
0.3 mul !q

(0,0,1) :p (0,0,1) cross :alpha 0.5 mul rot_vec
:thickness mul !r

[ :p :q add :r add
  :p :q sub :r add
  :p :q sub :r sub
  :p :q add :r sub
] 4 poly2doubleface !e
:e edgemate faceCCW 1 bridgerings-simple pop
:e
} forx

:e0 edgemate faceCW 1 bridgerings-simple pop
