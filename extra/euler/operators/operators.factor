! Copyright (C) 2010 Slava Pestov.
USING: accessors combinators fry kernel locals namespaces
game.models.half-edge euler.b-rep sequences typed math
math.vectors ;
IN: euler.operators

ERROR: edges-not-incident ;

: assert-incident ( e1 e2 -- )
    incident? [ edges-not-incident ] unless ;

ERROR: should-not-be-equal obj1 obj2 ;

: assert-not= ( obj1 obj2 -- )
    2dup eq? [ should-not-be-equal ] [ 2drop ] if ;

ERROR: edges-in-different-faces ;

: assert-same-face ( e1 e2 -- )
    same-face? [ edges-in-different-faces ] unless ;

ERROR: edges-in-same-face ;

: assert-different-faces ( e1 e2 -- )
    same-face? [ edges-in-same-face ] when ;

: assert-isolated-component ( edge -- )
    [ [ opposite-edge>> ] [ next-edge>> ] bi assert= ]
    [ dup opposite-edge>> assert-same-face ]
    bi ;

ERROR: not-a-base-face face ;

: assert-base-face ( face -- )
    dup base-face? [ drop ] [ not-a-base-face ] if ;

ERROR: has-rings face ;

: assert-no-rings ( face -- )
    dup next-ring>> [ has-rings ] [ drop ] if ;

: assert-ring-of ( ring face -- )
    [ base-face>> ] dip assert= ;

: with-b-rep ( b-rep quot -- )
    [ b-rep ] dip with-variable ; inline

: make-b-rep ( quot -- b-rep )
    <b-rep> [ swap with-b-rep ] [ finish-b-rep ] [ ] tri ; inline

<PRIVATE

:: make-loop ( vertex face -- edge )
    b-rep get new-edge :> edge
    vertex edge vertex<<
    edge edge next-edge<<
    face edge face<<

    edge ;

: make-loop-face ( vertex -- edge )
    b-rep get new-face
    dup >>base-face
    make-loop ;

:: make-edge ( vertex next-edge -- edge )
    b-rep get new-edge :> edge
    vertex edge vertex<<
    next-edge edge next-edge<<
    next-edge face>> edge face<<

    edge ;

: opposite-edges ( e1 e2 -- )
    [ opposite-edge<< ] [ swap opposite-edge<< ] 2bi ;

PRIVATE>

MIXIN: point
INSTANCE: sequence point
INSTANCE: number point

TYPED:: make-vefs ( pos1: point pos2: point -- edge: b-edge )
    b-rep get :> b-rep

    pos1 b-rep new-vertex :> v1
    v1 make-loop-face :> e1

    pos2 b-rep new-vertex :> v2
    v2 e1 make-edge :> e2

    e2 e1 next-edge<<
    e1 e2 opposite-edges

    e2 ;

TYPED:: make-ev-one ( edge: b-edge point: point -- edge: b-edge )
    point b-rep get new-vertex :> v
    v edge make-edge :> e1'

    edge vertex>> e1' make-edge :> e2'

    e2' edge face-cw next-edge<<
    e1' e2' opposite-edges

    e1' ;

<PRIVATE

:: subdivide-vertex-cycle ( e1 e2 v -- )
    e1 e2 eq? [
        v e1 vertex<<
        e1 vertex-cw e2 v subdivide-vertex-cycle
    ] unless ;

:: (make-ev) ( e1 e2 point -- edge )
    e1 e2 assert-incident

    point b-rep get new-vertex :> v'
    v' e2 make-edge :> e1'

    e1 vertex>> :> v

    v e1 make-edge :> e2'

    e1 e2 v' subdivide-vertex-cycle

    e1 face-cw :> e1p
    e2 face-cw :> e2p
    e1 opposite-edge>> :> e1m

    e1m e1p assert-not=

    e1' e2p next-edge<<
    e2' e1p next-edge<<

    e1' e2' opposite-edges

    e1' ;

PRIVATE>

TYPED:: make-ev ( e1: b-edge e2: b-edge point: point -- edge: b-edge )
    e1 e2 eq?
    [ e1 point make-ev-one ] [ e1 e2 point (make-ev) ] if ;

<PRIVATE

: subdivide-edge-cycle ( face e1 e2 -- )
    2dup eq? [ 3drop ] [
        [ drop face<< ]
        [ [ next-edge>> ] dip subdivide-edge-cycle ] 3bi
    ] if ;

PRIVATE>

TYPED:: make-ef ( e1: b-edge e2: b-edge -- edge: b-edge )
    e1 e2 assert-same-face

    e2 vertex>> make-loop-face :> e1'
    e1 vertex>> e2 make-edge :> e2'
    e1' e2' opposite-edges

    e1 face-cw :> e1p

    e1 e2 eq? [
        e2 face-cw :> e2p

        e1' face>> e1 e2 subdivide-edge-cycle

        e1' e2p next-edge<<
        e1 e1' next-edge<<
    ] unless

    e2' e1p next-edge<<
    e1' ;

TYPED:: make-e-kill-r ( edge-ring: b-edge edge-face: b-edge -- edge: b-edge )
    edge-ring face>> :> ring
    edge-face face>> :> face
    ring face assert-ring-of

    edge-ring [ face >>face drop ] each-face-edge

    edge-ring vertex>> edge-face make-edge :> e1
    edge-face vertex>> edge-ring make-edge :> e2

    ring face delete-ring
    ring b-rep get delete-face

    e2 edge-face face-cw next-edge<<
    e1 edge-ring face-cw next-edge<<

    e1 e2 opposite-edges

    e1 ;

TYPED:: make-f-kill-rh ( edge-ring: b-edge -- )
    edge-ring face>> :> ring
    ring base-face>> :> base-face
    ring base-face delete-ring
    ring ring base-face<< ;

TYPED:: kill-vefs ( edge: b-edge -- )
    edge assert-isolated-component

    b-rep get :> b-rep
    edge dup opposite-edge>> :> ( e2 e1 )

    e1 vertex>> :> v1
    e2 vertex>> :> v2

    e1 face>> b-rep delete-face

    e1 b-rep delete-edge
    e2 b-rep delete-edge
    v1 b-rep delete-vertex
    v2 b-rep delete-vertex ;

TYPED:: kill-ev ( edge: b-edge -- )
    b-rep get :> b-rep

    edge vertex>> :> v
    edge opposite-edge>> :> edge'
    edge' vertex>> :> v'

    edge [ v' >>vertex drop ] each-vertex-edge

    edge face-cw :> edgep
    edge' face-cw :> edge'p

    edge next-edge>> edgep next-edge<<
    edge' next-edge>> edge'p next-edge<<

    v b-rep delete-vertex
    edge b-rep delete-edge
    edge' b-rep delete-edge ;

TYPED:: kill-ef ( edge: b-edge -- )
    b-rep get :> b-rep

    edge :> e1
    edge opposite-edge>> :> e2

    e1 e2 assert-different-faces

    e1 face-cw :> e1p
    e2 face-cw :> e2p

    e1 face>> :> f1
    e2 face>> :> f2

    e1 [ f2 >>face drop ] each-face-edge
    f1 b-rep delete-face

    e1 e2 incident? [
        e2 next-edge>> e2p next-edge<<

    ] [
        e2 next-edge>> e1p next-edge<<
        e1 next-edge>> e2p next-edge<<
    ] if

    e1 b-rep delete-edge
    e2 b-rep delete-edge ;

TYPED:: kill-e-make-r ( edge: b-edge -- edge-ring: b-edge )
    b-rep get :> b-rep

    edge opposite-edge>> :> edge'
    edge' next-edge>> :> edge-ring
    edge-ring opposite-edge>> :> edge-ring'

    edge edge' assert-same-face
    edge edge-ring assert-same-face
    edge edge-ring' assert-different-faces

    b-rep new-face :> ring

    ring edge face>> base-face>> add-ring
    ring edge' edge subdivide-edge-cycle

    edge b-rep delete-edge
    edge' b-rep delete-edge

    edge-ring ;

TYPED:: kill-f-make-rh ( edge-face: b-edge edge-base-face: b-edge -- )
    edge-face face>> :> face
    edge-base-face face>> :> base-face

    face assert-base-face
    base-face assert-base-face
    edge-face edge-base-face assert-different-faces

    face base-face add-ring ;

TYPED: move-v ( edge: b-edge point: point -- )
    swap vertex>> position<< ;

TYPED: move-e ( edge: b-edge offset: point -- )
    [ dup opposite-edge>> ] dip
    '[ vertex>> [ _ v+ ] change-position drop ] bi@ ;

TYPED: move-f ( edge: b-edge offset: point -- )
    '[ vertex>> [ _ v+ ] change-position drop ] each-face-edge ;

TYPED: sharp-e ( edge: b-edge sharp?: boolean -- )
    >>sharpness drop ;

TYPED: sharp-f ( edge: b-edge sharp?: boolean -- )
    '[ _ sharp-e ] each-face-edge ;

TYPED: sharp-v ( edge: b-edge sharp?: boolean -- )
    '[ _ sharp-e ] each-vertex-edge ;

TYPED: material-f ( edge: b-edge material -- ) 2drop ;
