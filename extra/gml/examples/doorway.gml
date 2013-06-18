usereg !nrml !backwall !wall !poly
{ usereg !door !wall
    :door edgemate :wall killFmakeRH
    :door edgemate faceCCW
    :wall makeEkillR
    dup faceCCW faceCCW
    :door edgemate
    exch makeEF pop
    faceCCW killEF
} !glue-ringface-edges

:poly 0 get                     !pr
:poly -1 get                    !pl
:wall vertexpos                 !pw0
:wall edgemate vertexpos        !pw1
:pr :pw0 :pw1 project_ptline    !prb
:pl :pw0 :pw1 project_ptline    !plb
[ :plb :plb :prb :prb ]
:poly arrayappend               !poly

:poly :nrml neg :backwall faceplane
project_polyplane
    5 poly2doubleface edgemate  !backdoor
:poly 5 poly2doubleface         !door
:wall     :door     :glue-ringface-edges
:backwall :backdoor :glue-ringface-edges
:backdoor faceCCW :door 2 bridgerings

!doorL
:doorL edgemate 2 faceCCW edgemate !doorR
:doorL edgemate faceCCW killEF
:doorR edgemate faceCCW killEmakeR pop
:doorL edgemate isBaseface {
    :doorR edgemate makeFkillRH
} if

:doorL :doorR
