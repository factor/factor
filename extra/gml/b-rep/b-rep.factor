! Copyright (C) 2010 Slava Pestov.
USING: accessors euler.b-rep euler.operators
game.models.half-edge gml.macros gml.printer gml.runtime
gml.types io io.styles kernel namespaces ;
FROM: alien.c-types => >c-bool c-bool> ;
IN: gml.b-rep

LOG-GML: makeVEFS ( p1 p2 -- edge ) make-vefs ;

LOG-GML: makeEV ( e0 e1 p -- edge ) make-ev ;

LOG-GML: makeEVone ( e0 p -- edge ) dupd make-ev ;

LOG-GML: makeEF ( e1 e2 -- edge ) make-ef ;

LOG-GML: makeEkillR ( edge-ring edge-face -- edge ) make-e-kill-r ;

LOG-GML: makeFkillRH ( edge-ring -- ) make-f-kill-rh ;

LOG-GML: killVEFS ( edge -- ) kill-vefs ;

LOG-GML: killEV ( edge -- ) kill-ev ;

LOG-GML: killEF ( edge -- ) kill-ef ;

LOG-GML: killEmakeR ( edge -- edge-ring ) kill-e-make-r ;

LOG-GML: killFmakeRH ( face-edge base-face-edge -- ) kill-f-make-rh ;

GML: moveV ( edge point -- ) move-v ;

GML: moveE ( edge offset -- ) move-e ;

GML: moveF ( edge offset -- ) move-f ;

GML: vertexCW ( e0 -- e1 ) vertex-cw ;

GML: vertexCCW ( e0 -- e1 ) vertex-ccw ;

GML: faceCW ( e0 -- e1 ) face-cw ;

GML: faceCCW ( e0 -- e1 ) face-ccw ;

GML: baseface ( e0 -- e1 ) base-face>> ;

GML: nextring ( e0 -- e1 ) [ next-ring>> ] [ base-face>> ] ?unless ;

GML: facenormal ( e0 -- n ) face-normal ;
GML: faceplanedist ( e0 -- d ) face-plane-dist ;
GML: faceplane  ( e0 -- n d ) face-plane ;

GML: facemidpoint ( e0 -- v ) face-midpoint ;

GML: facedegree ( e0 -- n ) face-sides ;

GML: edgemate ( e0 -- e1 ) opposite-edge>> ;
GML: edgeflip ( e0 -- e1 ) opposite-edge>> ;

GML: edgedirection ( e0 -- v ) edge-direction ;

GML: vertexpos ( e0 -- p ) vertex-pos ;

GML: valence ( e0 -- n ) vertex-valence ;

GML: sameEdge ( e0 e1 -- ? ) same-edge? >true ;

GML: sameFace ( e0 e1 -- ? ) same-face? >true ;

GML: sameVertex ( e0 e1 -- ? ) incident? >true ;

GML: isBaseface ( e -- ? ) face>> base-face? ;

GML: sharpE ( e sharp -- ) c-bool> sharp-e ;

GML: sharpF ( e sharp -- ) c-bool> sharp-f ;

GML: sharpV ( e sharp -- ) c-bool> sharp-v ;

GML: issharp ( e -- sharp ) sharpness>> >c-bool ;

GML: isValidEdge ( e -- ? ) b-rep get is-valid-edge? ;

GML: materialF ( e material -- ) material-f ;

GML: setcurrentmaterial ( material -- ) drop ;
GML: getcurrentmaterial ( -- material ) "none" >gml-name ;
GML: pushcurrentmaterial ( material -- ) drop ;
GML: popcurrentmaterial ( -- material ) "none" >gml-name ;
GML: getmaterialnames ( -- [material] ) { } ;
GML: setfacematerial ( e material -- ) material-f ;
GML: getfacematerial ( e -- material ) drop "none" >gml-name ;

GML: setsharpness ( sharp -- ) c-bool> set-sharpness ;
GML: getsharpness ( -- sharp ) get-sharpness >c-bool ;
GML: pushsharpness ( sharp -- ) c-bool> push-sharpness ;
GML: popsharpness ( -- sharp ) pop-sharpness >c-bool ;

GML: connectedvertices ( e0 e1 -- connected )
    ! Stupid variable-arity word!
    connecting-edge [ [ over push-operand ] when* ] [ >c-bool ] bi ;

M: b-edge write-gml
    dup vertex>> position>> vertex-style [
        "«Edge " write
        [ vertex>> position>> write-gml "-" write ] [
            opposite-edge>> vertex>> position>>
            dup vertex-style [ write-gml ] with-style
        ] bi
        "»" write
    ] with-style ;
