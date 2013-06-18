usereg

(1,1,1) !v0
(1,0,1) !v1
(0,0,1) !v2
(0,1,1) !v3

(1,1,0) !v4
(1,0,0) !v5
(0,0,0) !v6
(0,1,0) !v7

:v0 :v1 makeVEFS dup
[ :v2 :v3 ]
{ makeEVone } forall
exch edgemate exch makeEF

:v7 makeEVone
dup faceCCW faceCCW
[ :v4 :v5 :v6 ]
{
    makeEVone
    makeEF vertexCW
    dup faceCCW faceCCW
} forall
faceCCW makeEF

edgemate !e
:e :e facemidpoint
:e facenormal add

!p !e
:e :p makeEVone
dup edgemate !e
{
    dup faceCCW faceCCW
    dup :e eq { exit } if
    makeEF edgemate
} loop

pop pop
