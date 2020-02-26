! Copyright (C) 2010 Slava Pestov.
USING: accessors combinators fry kernel locals math.vectors
namespaces sets sequences game.models.half-edge euler.b-rep
euler.operators math ;
IN: euler.modeling

: (polygon>double-face) ( polygon -- edge )
    [ first2 make-vefs ] keep
    [ drop opposite-edge>> ] [ 2 tail-slice [ make-ev-one ] each ] 2bi
    make-ef face-ccw ;

SYMBOLS: smooth-smooth
sharp-smooth
smooth-sharp
sharp-sharp
smooth-like-vertex
sharp-like-vertex
smooth-continue
sharp-continue ;

: polygon>double-face ( polygon mode -- edge )
    ! This only handles the simple case with no repeating vertices
    drop
    dup all-unique? [ "polygon>double-face doesn't support repeating vertices yet" throw ] unless
    (polygon>double-face) ;

:: extrude-simple ( edge dist sharp? -- edge )
    edge face-normal dist v*n :> vec
    edge vertex-pos vec v+ :> pos
    edge pos make-ev-one :> e0!
    e0 opposite-edge>> :> e-end
    edge face-ccw :> edge!

    [ edge e-end eq? not ] [
        edge vertex-pos vec v+ :> pos
        edge pos make-ev-one :> e1
        e0 e1 make-ef drop
        e1 e0!
        edge face-ccw edge!
    ] do while

    e-end face-ccw :> e-end
    e0 e-end make-ef drop

    e-end ;

: check-bridge-rings ( e1 e2 -- )
    {
        [ [ face>> assert-no-rings ] bi@ ]
        [ [ face>> assert-base-face ] bi@ ]
        [ assert-different-faces ]
        [ [ face-sides ] bi@ assert= ]
    } 2cleave ;

:: bridge-rings-simple ( e1 e2 sharp? -- edge )
    e1 e2 check-bridge-rings
    e1 e2 kill-f-make-rh
    e1 e2 make-e-kill-r face-cw :> ea!
    e2 face-ccw :> eb!
    [ ea e1 eq? not ] [
        ea eb make-ef opposite-edge>> face-cw ea!
        eb face-ccw eb!
    ] while
    eb ;

:: project-pt-line ( p p0 p1 -- q )
    p1 p0 v- :> vt
    p p0 v- vt vdot
    vt norm-sq /
    vt n*v p0 v+ ; inline

:: project-pt-plane ( line-p0 line-vt plane-n plane-d -- q )
    plane-d neg plane-n line-p0 vdot -
    line-vt plane-n vdot /
    line-vt n*v line-p0 v+ ; inline

: project-poly-plane ( poly vdir plane-n plane-d -- qoly )
    '[ _ _ _ project-pt-plane ] map ; inline
