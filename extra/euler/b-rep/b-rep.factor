! Copyright (C) 2010 Slava Pestov.
USING: accessors arrays assocs combinators
combinators.short-circuit game.models.half-edge kernel math
math.vectors namespaces sequences sets ;
FROM: namespaces => set ;
IN: euler.b-rep

: >index-hash ( seq -- hash ) H{ } zip-index-as ; inline

TUPLE: b-edge < edge sharpness macro ;

TUPLE: vertex < identity-tuple position edge ;

TUPLE: face < identity-tuple edge next-ring base-face ;

:: (opposite) ( e1 e2 quot: ( edge -- edge' ) -- edge )
    e1 quot call :> e0
    e0 e2 eq? [ e1 ] [ e0 e2 quot (opposite) ] if ;
    inline recursive

: opposite ( edge quot: ( edge -- edge' ) -- edge )
    dupd (opposite) ; inline

: face-ccw ( edge -- edge ) next-edge>> ; inline

: face-cw ( edge -- edge ) [ face-ccw ] opposite ; inline

: vertex-cw ( edge -- edge ) opposite-edge>> next-edge>> ; inline

: vertex-ccw ( edge -- edge ) [ vertex-cw ] opposite ; inline

: base-face? ( face -- ? ) dup base-face>> eq? ; inline

: has-rings? ( face -- ? ) next-ring>> >boolean ; inline

: incident? ( e1 e2 -- ? ) [ vertex>> ] bi@ eq? ; inline

TUPLE: b-rep < identity-tuple faces edges vertices ;

: <b-rep> ( -- b-rep )
    V{ } clone V{ } clone V{ } clone b-rep boa ;

SYMBOL: sharpness-stack
sharpness-stack [ V{ t } ] initialize

: set-sharpness ( sharp? -- ) >boolean sharpness-stack get set-last ;
: get-sharpness ( -- sharp? ) sharpness-stack get last ;

: push-sharpness ( sharp? -- ) >boolean sharpness-stack get push ;
: pop-sharpness ( -- sharp? )
    sharpness-stack get
    dup length 1 = [ first ] [ pop ] if ;

: new-vertex ( position b-rep -- vertex )
    [ f vertex boa dup ] dip vertices>> push ; inline

: new-edge ( b-rep -- edge )
    [ b-edge new get-sharpness >>sharpness dup ] dip edges>> push ; inline

: new-face ( b-rep -- face )
    [ face new dup ] dip faces>> push ; inline

: delete-vertex ( vertex b-rep -- )
    vertices>> remove! drop ; inline

: delete-edge ( edge b-rep -- )
    edges>> remove! drop ; inline

: delete-face ( face b-rep -- )
    faces>> remove! drop ; inline

: add-ring ( ring base-face -- )
    [ >>base-face drop ]
    [ next-ring>> >>next-ring drop ]
    [ swap >>next-ring drop ]
    2tri ;

: delete-ring ( ring base-face -- )
    2dup next-ring>> eq?
    [ [ next-ring>> ] dip next-ring<< ]
    [ next-ring>> delete-ring ]
    if ;

: vertex-pos ( edge -- pos )
    vertex>> position>> ; inline

: same-edge? ( e1 e2 -- ? )
    { [ eq? ] [ opposite-edge>> eq? ] } 2|| ;

: same-face? ( e1 e2 -- ? )
    [ face>> ] bi@ eq? ;

: edge-direction ( edge -- v )
    [ face-ccw ] keep [ vertex-pos ] bi@ v- ;

: normal ( v0 v1 v2 -- v )
    [ drop v- ] [ nipd v- ] 3bi cross ;

ERROR: all-points-colinear ;

: face-normal ( edge -- n )
    face-edges
    [
        dup face-ccw dup face-ccw
        [ vertex-pos ] tri@ normal
    ] map
    [ [ zero? ] all? not ] find nip
    [ normalize ] [ all-points-colinear ] if* ;

: (face-plane-dist) ( normal edge -- d )
    vertex-pos vdot neg ; inline

: face-plane-dist ( edge -- d )
    [ face-normal ] [ (face-plane-dist) ] bi ; inline

: face-plane ( edge -- n d )
    [ face-normal dup ] [ (face-plane-dist) ] bi ; inline

: face-midpoint ( edge -- v )
    face-edges
    [ [ vertex-pos ] [ v+ ] map-reduce ] [ length ] bi v/n ;

: clear-b-rep ( b-rep -- )
    [ faces>> delete-all ]
    [ edges>> delete-all ]
    [ vertices>> delete-all ]
    tri ;

: connect-opposite-edges ( b-rep -- )
    edges>>
    [ [ [ next-edge>> vertex>> ] [ vertex>> 2array ] [ ] tri ] H{ } map>assoc ]
    [ swap '[ [ vertex>> ] [ next-edge>> vertex>> 2array _ at ] [ opposite-edge<< ] tri ] each ] bi ;

: connect-faces ( b-rep -- )
    edges>> [ dup face>> edge<< ] each ;

: connect-vertices ( b-rep -- )
    edges>> [ dup vertex>> edge<< ] each ;

: finish-b-rep ( b-rep -- )
    [ connect-faces ] [ connect-vertices ] bi ;

: characteristic ( b-rep -- n )
    ! Assumes b-rep is connected and all faces are convex
    [ vertices>> length ]
    [ edges>> length 2 / ]
    [ faces>> [ base-face? ] count ] tri
    [ - ] dip + ;

: genus ( b-rep -- n )
    ! Assumes b-rep is connected and all faces are convex
    characteristic 2 swap - 2 / ;

SYMBOLS: live-vertices live-edges live-faces ;

ERROR: dead-vertex vertex ;

: check-live-vertex ( vertex -- )
    dup live-vertices get in? [ drop ] [ dead-vertex ] if ;

ERROR: dead-edge edge ;

: check-live-edge ( edge -- )
    dup live-edges get in? [ drop ] [ dead-edge ] if ;

ERROR: dead-face face ;

: check-live-face ( face -- )
    dup live-faces get in? [ drop ] [ dead-face ] if ;

: check-vertex ( vertex -- )
    [ edge>> check-live-edge ]
    [ dup edge>> [ vertex>> assert= ] with each-vertex-edge ]
    bi ;

: check-edge ( edge -- )
    {
        [ vertex>> check-live-vertex ]
        [ opposite-edge>> check-live-edge ]
        [ face>> check-live-face ]
        [ dup opposite-edge>> opposite-edge>> assert= ]
    } cleave ;

: check-face ( face -- )
    [ edge>> check-live-edge ]
    [ dup edge>> [ face>> assert= ] with each-face-edge ]
    bi ;

: check-ring ( base-face face -- )
    [ check-face ] [ base-face>> assert= ] bi ;

: check-base-face ( face -- )
    [ check-face ]
    [ dup [ next-ring>> ] follow rest [ check-ring ] with each ] bi ;

: check-b-rep ( b-rep -- )
    [
        [
            [ vertices>> fast-set live-vertices set ]
            [ edges>> fast-set live-edges set ]
            [ faces>> fast-set live-faces set ] tri
        ]
        [
            [ vertices>> [ check-vertex ] each ]
            [ edges>> [ check-edge ] each ]
            [ faces>> [ base-face? ] filter [ check-base-face ] each ] tri
        ] bi
    ] with-scope ;

: empty-b-rep? ( b-rep -- ? )
    [ faces>> ] [ edges>> ] [ vertices>> ] tri
    [ empty? ] tri@ and and ;

ERROR: b-rep-not-empty b-rep ;

: assert-empty-b-rep ( b-rep -- )
    dup empty-b-rep? [ drop ] [ b-rep-not-empty ] if ;

: is-valid-edge? ( e brep -- ? )
    edges>> member? ; inline

: edge-endpoints ( edge -- from to )
    [ vertex>> position>> ]
    [ opposite-edge>> vertex>> position>> ] bi ; inline

:: connecting-edge ( e0 e1 -- edge/f )
    e1 vertex>> :> target-vertex
    e0 vertex>> target-vertex eq? [ f ] [
        f e0 [| ret edge |
            edge opposite-edge>> vertex>> target-vertex eq?
            [ edge edge f ]
            [ f edge vertex-cw dup e0 eq? not ] if
        ] loop drop
    ] if ;
